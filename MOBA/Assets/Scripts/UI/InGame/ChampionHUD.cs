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
    [SerializeField] private Image healthBar;
    [SerializeField] private Image resourceBar;
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
    private Champion champion;
    private IResourceable resourceable;
    private IActiveLifeable lifeable;
    private ICastable castable;
    private SpellHolder passiveHolder;
    private Dictionary<byte, SpellHolder> spellHolderDict = new Dictionary<byte, SpellHolder>();

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

        public void StartTimer(float coolDown)
        {
            var timer = 0.0;
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
                timer += 1.0 / tckRate;
                spellCooldown.fillAmount = 1 - (float)(timer / coolDown);
                if (!(timer > coolDown)) return;
                if (PhotonNetwork.IsMasterClient)
                {
                    GameStateMachine.Instance.OnTick -= TickMaster;
                }
                else
                {
                    GameStateMachine.Instance.OnTickFeedback -= TickClient;
                }

                spellCooldown.fillAmount = 0;
            }

            void TickClient(double timeDiff)
            {
                timer += timeDiff;

                spellCooldown.fillAmount = 1 - (float)(timer / coolDown);
                if (!(timer > coolDown)) return;
                if (PhotonNetwork.IsMasterClient)
                {
                    GameStateMachine.Instance.OnTick -= TickMaster;
                }
                else
                {
                    GameStateMachine.Instance.OnTickFeedback -= TickClient;
                }

                spellCooldown.fillAmount = 0;
            }
        }
    }

    public void InitHUD(Champion newChampion)
    {
        champion = newChampion;
        lifeable = champion.GetComponent<IActiveLifeable>();
        resourceable = champion.GetComponent<IResourceable>();
        castable = champion.GetComponent<ICastable>();

        healthBar.fillAmount = lifeable.GetCurrentHpPercent();
        resourceBar.fillAmount = resourceable.GetCurrentResourcePercent();
        LinkToEvents();
        UpdateIcons(champion);
    }

    private void InitHolders()
    {
        var so = champion.championSo;
        spellPassive.sprite = champion.passiveCapacitiesList[0].AssociatedPassiveCapacitySO().icon;
        spellOne.sprite = so.activeCapacities[0].icon;
        spellTwo.sprite = so.activeCapacities[1].icon;
        spellUltimate.sprite = so.ultimateAbility.icon;
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

        resourceable.OnSetCurrentResourceFeedback += UpdateFillPercentResource;
        resourceable.OnSetCurrentResourcePercentFeedback += UpdateFillPercentByPercentResource;
        resourceable.OnIncreaseCurrentResourceFeedback += UpdateFillPercentResource;
        resourceable.OnDecreaseCurrentResourceFeedback += UpdateFillPercentResource;
        resourceable.OnIncreaseMaxResourceFeedback += UpdateFillPercentResource;
        resourceable.OnDecreaseMaxResourceFeedback += UpdateFillPercentResource;
    }

    private void UpdateIcons(Champion champion)
    {
        var so = champion.championSo;
        passiveHolder = new SpellHolder
        {
            spellIcon = spellPassive,
            spellCooldown = spellPassiveCooldown
        };
        var spellOneHolder = new SpellHolder
        {
            spellIcon = spellOne,
            spellCooldown = spellOneCooldown
        };
        var spellTwoHolder = new SpellHolder
        {
            spellIcon = spellTwo,
            spellCooldown = spellTwoCooldown
        };
        var spellThreeHolder = new SpellHolder
        {
            spellIcon = spellThree,
            spellCooldown = spellThreeCooldown
        };
        var ultimateHolder = new SpellHolder
        {
            spellIcon = spellUltimate,
            spellCooldown = spellUltimateCooldown
        };

        spellHolderDict.Add(0, spellOneHolder);
        spellHolderDict.Add(1, spellTwoHolder);
        spellHolderDict.Add(2, spellThreeHolder);
        spellHolderDict.Add(3, ultimateHolder);

        if (so.passiveCapacities.Length != 0)
            passiveHolder.Setup(so.passiveCapacities[0].icon);
        if (so.activeCapacities.Length > 0)
        {
            spellOneHolder.Setup(so.activeCapacities[0].icon);
        }

        if (so.activeCapacities.Length > 1)
        {
            spellTwoHolder.Setup(so.activeCapacities[1].icon);
        }

        if (so.activeCapacities.Length > 2)
            spellThreeHolder.Setup(so.activeCapacities[2].icon);

        if (so.ultimateAbility)
        {
            ultimateHolder.Setup(so.ultimateAbility.icon);
        }
    }

    private void UpdateCooldown(byte capacityIndex, bool inCooldown)
    {
        if (inCooldown && champion.photonView.IsMine)
        {
            for (byte i = 0; i < champion.activeCapacities.Count; i++)
            {
                if (champion.activeCapacities[i].indexOfSOInCollection == capacityIndex)
                {
                    spellHolderDict[i].StartTimer(CapacitySOCollectionManager.GetActiveCapacitySOByIndex(capacityIndex)
                        .cooldown);
                    return;
                }
            }
        }
    }

    private void UpdateFillPercentByPercentHealth(float value)
    {
        healthBar.fillAmount = lifeable.GetCurrentHp() / lifeable.GetMaxHp();
    }

    private void UpdateFillPercentHealth(float value)
    {
        healthBar.fillAmount = lifeable.GetCurrentHp() / lifeable.GetMaxHp();
    }

    private void UpdateFillPercentByPercentResource(float value)
    {
        resourceBar.fillAmount = value;
    }

    private void UpdateFillPercentResource(float value)
    {
        resourceBar.fillAmount = resourceable.GetCurrentResource();
    }
}