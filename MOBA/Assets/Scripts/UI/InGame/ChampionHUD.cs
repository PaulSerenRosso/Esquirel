using System;
using System.Collections.Generic;
using Entities;
using Entities.Capacities;
using Entities.Champion;
using GameStates;
using Photon.Pun;
using UnityEngine;
using UnityEngine.UI;

public class ChampionHUD : MonoBehaviour
{
    /*
    [SerializeField] private Image healthBar;
  //  [SerializeField] private Image resourceBar;
    [SerializeField] private Image spellPassive;
    [SerializeField] private Image spellOne;
    [SerializeField] private Image spellTwo;
    [SerializeField] private Image spellThree;
    [SerializeField] private Image spellUltimate;
    [SerializeField] private Image spellPassiveCooldown;
    [SerializeField] private Image spellOneCooldown;
    [SerializeField] private Image spellTwoCooldown;
    [SerializeField] private Image spellThreeCooldown;
    [SerializeField] private Image spellUltimateCooldown;
    */
    // private SpellHolder passiveHolder;
  //  private Dictionary<byte, SpellHolder> spellHolderDict = new Dictionary<byte, SpellHolder>();
  public Champion champion;
    private IResourceable resourceable;
    private IActiveLifeable lifeable;
    private PlayerInterface playerInterface;

    private Champion otherChampion; 
    /*
    public class SpellHolder
    {
        public Image spellIcon;
        public Image spellCooldown;

        public void Setup(Sprite image)
        {
            spellIcon.sprite = image;
            spellCooldown.fillAmount = 0;
        }

        public void ChangeIcon(Sprite image)
        {
            spellIcon.sprite = image;
        }

     
        }
    }
    */

    public void StartTimer(float coolDown, PlayerUIImage playerUIImage)
    {
        float timer = 0;
        var tckRate = GameStateMachine.Instance.tickRate;

        if (PhotonNetwork.IsMasterClient)
        {
            GameStateMachine.Instance.OnTick += TickMaster;
        }
        else
        {
            GameStateMachine.Instance.OnTickFeedback += TickClient;
        }
        
        void TickMaster()
        {
            timer += (float)(1.0 / tckRate);
            playerInterface.UpdateSpellTimer(playerUIImage, timer, coolDown);
            if (!(timer > coolDown)) return;
            if (PhotonNetwork.IsMasterClient)
            {
                GameStateMachine.Instance.OnTick -= TickMaster;
            }
            else
            {
                GameStateMachine.Instance.OnTickFeedback -= TickClient;
            }

            playerInterface.UpdateSpellTimer(playerUIImage, 0, coolDown);
        }

        void TickClient(double timeDiff)
        {
            timer += (float)timeDiff;

            playerInterface.UpdateSpellTimer(playerUIImage, timer, coolDown);
            if (!(timer > coolDown)) return;
            if (PhotonNetwork.IsMasterClient)
            {
                GameStateMachine.Instance.OnTick -= TickMaster;
            }
            else
            {
                GameStateMachine.Instance.OnTickFeedback -= TickClient;
            }

            playerInterface.UpdateSpellTimer(playerUIImage, 0, coolDown);
        }
    }

    public void InitHUD(Champion newChampion, PlayerInterface playerInterface)
    {
        champion = newChampion;
        lifeable = champion.GetComponent<IActiveLifeable>();
       otherChampion = GameStateMachine.Instance.GetOtherChampionOfSameTeam(champion);
        resourceable = champion.GetComponent<IResourceable>();
        this.playerInterface = playerInterface;
        playerInterface.UpdateHealth(lifeable);
        LinkToEvents();
        UpdateIcons(champion);
    }
    
    private void LinkToEvents()
    {
        champion.OnSetCooldownFeedback += UpdateCooldown;

        lifeable.OnSetCurrentHpFeedback += UpdateFillPercentHealth;
        lifeable.OnSetCurrentHpPercentFeedback += UpdateFillPercentByPercentHealth;
        lifeable.OnIncreaseCurrentHpFeedback += UpdateFillPercentHealth;
        lifeable.OnDecreaseCurrentHpFeedback += UpdateFillPercentHealth;
        lifeable.OnIncreaseMaxHpFeedback += UpdateFillPercentHealth;
        lifeable.OnDecreaseMaxHpFeedback += UpdateFillPercentHealth;
        if(!otherChampion) return;
        otherChampion.OnSetCurrentHpFeedback += UpdateOtherChampionFillPercentHealth;
        otherChampion.OnSetCurrentHpPercentFeedback += UpdateOtherChampionFillPercentByPercentHealth;
        otherChampion.OnIncreaseCurrentHpFeedback += UpdateOtherChampionFillPercentHealth;
        otherChampion.OnDecreaseCurrentHpFeedback += UpdateOtherChampionFillPercentHealth;
        otherChampion.OnIncreaseMaxHpFeedback += UpdateOtherChampionFillPercentHealth;
        otherChampion.OnDecreaseMaxHpFeedback += UpdateOtherChampionFillPercentHealth;
    }

    private void UpdateIcons(Champion champion)
    {
        var so = champion.championSo;
        playerInterface.SetUpImageVisual(PlayerUIImage.Spell01, so.activeCapacities[0].icon);
        playerInterface.SetUpImageVisual(PlayerUIImage.Spell02, so.activeCapacities[1].icon);
        playerInterface.SetUpImageVisual(PlayerUIImage.Ward, so.activeCapacities[2].icon);
        playerInterface.SetUpImageVisual(PlayerUIImage.AutoAttack, so.attackAbility.icon);
        playerInterface.SetUpImageVisual(PlayerUIImage.PlayerCharacter, so.championIcon);
    }

    private void UpdateCooldown(byte capacityIndex, bool inCooldown)
    {
        if (inCooldown && champion.photonView.IsMine)
        {
            if (champion.attackBase.indexOfSOInCollection == capacityIndex)
            {
                StartTimer(CapacitySOCollectionManager.GetActiveCapacitySOByIndex(capacityIndex)
                    .cooldown, PlayerUIImage.AutoAttack);
                return;
            }
            for (byte i = 0; i < champion.championSo.activeCapacities.Length; i++)
            {
                if (champion.championSo.activeCapacities[i].indexInCollection == capacityIndex)
                {
                    switch (i)
                    {
                        case 2 :
                        {
                            StartTimer(CapacitySOCollectionManager.GetActiveCapacitySOByIndex(capacityIndex)
                                .cooldown, PlayerUIImage.Ward);
                            break;
                        }
                        case 0 :
                        {
                            StartTimer(CapacitySOCollectionManager.GetActiveCapacitySOByIndex(capacityIndex)
                                .cooldown, PlayerUIImage.Spell01);
                            break;
                        }
                        case 1:
                        {
                            StartTimer(CapacitySOCollectionManager.GetActiveCapacitySOByIndex(capacityIndex)
                                .cooldown, PlayerUIImage.Spell02);
                            break;
                        }

                    }
                  
                    return;
                }
            }
        }
    }

    private void UpdateFillPercentByPercentHealth(float value)
    {
        playerInterface.UpdateHealth(lifeable);
    }

    private void UpdateFillPercentHealth(float value)
    {
       playerInterface.UpdateHealth(lifeable);
    }
    
    private void UpdateOtherChampionFillPercentByPercentHealth(float value)
    {
        playerInterface.UpdateAllyHealth(otherChampion.GetCurrentHp(), otherChampion.GetMaxHp());
    }

    private void UpdateOtherChampionFillPercentHealth(float value)
    {
        playerInterface.UpdateAllyHealth(otherChampion.GetCurrentHp(), otherChampion.GetMaxHp());
    }


}