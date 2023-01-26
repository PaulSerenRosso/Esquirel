using System;
using GameStates;
using Photon.Pun;
using RessourceProduction;
using System.Collections.Generic;
using Entities;
using TMPro;
using UnityEngine.UI;
using UnityEngine;
using UnityEngine.Events;

public class PlayerInterface : MonoBehaviour
{
    [Header("Player Health")]
    [SerializeField] private List<Animator> healthAnimatorList = new List<Animator>();
    [SerializeField] private Image allyHealthBar = null;
    [SerializeField] private TextMeshProUGUI healthText = null;
    [SerializeField] private TextMeshProUGUI allyHealthText = null;

    [Header("Player Image")] 
    [SerializeField] private Image playerCharacterImage = null;

    [Header("Spell")] 
    [SerializeField] private Image autoAttackImage = null;
    [SerializeField] private Image spell01Image = null;
    [SerializeField] private Image spell01RecastImage = null;
    [SerializeField] private Image spell01Cooldown = null;
    [SerializeField] private TextMeshProUGUI spell01CooldownTxt = null;
    [SerializeField] private Image spell02Image = null;
    [SerializeField] private Image spell02Cooldown = null;
    [SerializeField] private TextMeshProUGUI spell02CooldownTxt = null;
    [SerializeField] private Image wardImage = null;
    [SerializeField] private Image wardCooldown = null;
    [SerializeField] private TextMeshProUGUI wardCooldownTxt = null;

    [Header("Gold")] 
    [SerializeField] private TextMeshProUGUI team01GoldValue = null;
    [SerializeField] private Image team01GoldImgValue = null;
    [SerializeField] private TextMeshProUGUI team01GoldStreak = null;
    [SerializeField] private Animator team01GoldExchangeAnim = null;
        
    [SerializeField] private TextMeshProUGUI team02GoldValue = null;
    [SerializeField] private Image team02GoldImgValue = null;
    [SerializeField] private TextMeshProUGUI team02GoldStreak = null;
    [SerializeField] private Animator team02GoldExchangeAnim = null;
    
    [SerializeField] private GameObject northRelaiRed = null;
    [SerializeField] private GameObject northRelaiBlue = null;
    [SerializeField] private GameObject southRelaiRed = null;
    [SerializeField] private GameObject southRelaiBlue = null;

    [Header("Victory")] 
    [SerializeField] private Image team01VictoryPoint = null;
    [SerializeField] private Image redGeneratorValue = null;
    [SerializeField] private Image team02VictoryPoint = null;
    [SerializeField] private Image blueGeneratorValue = null;

    [Header("Aura")]
    [SerializeField] private TextMeshProUGUI auraAvailableTxt = null;
    [SerializeField] private Image auraAvailableImg = null;
    [SerializeField] private Button AADamagebtn = null;
    [SerializeField] private Button COMP01Damagebtn = null;
    [SerializeField] private Button LifePointbtn = null;
    [SerializeField] private List<GameObject> AAAuraImages = new List<GameObject>(); 
    [SerializeField] private List<GameObject> CompAuraImages = new List<GameObject>(); 
    [SerializeField] private List<GameObject> LifeAuraImages = new List<GameObject>(); 

    /// <summary>
    /// Update the visual of the Health Bar
    /// </summary>
    /// <param name="currentHealth"></param>
    /// <param name="maxHealth"></param>
    public void UpdateHealth(IActiveLifeable lifeable) {
        for (int i = 0; i < healthAnimatorList.Count; i++) {
            if (i < lifeable.GetCurrentHp()) healthAnimatorList[i].SetInteger("Life", 1);
            else healthAnimatorList[i].SetInteger("Life", 0);
            
            healthAnimatorList[i].gameObject.SetActive(!(i >= lifeable.GetMaxHp()));
            healthText.text = $"<color=green>Life remaining</color> : {(int) lifeable.GetCurrentHp()} / {(int) lifeable.GetMaxHp()}";
        }
    }

    public void UpdateAllyHealth(float currentHealth, float maxHealth) {
        allyHealthBar.fillAmount = currentHealth / maxHealth;
        allyHealthText.text = $"<color=green>Ally life remaining</color> : {(int) currentHealth} / {(int) maxHealth}";
    }

    /// <summary>
    /// Update the visual of a player Interface Element
    /// </summary>
    /// <param name="imageType"></param>
    /// <param name="imageSprite"></param>
    /// <exception cref="ArgumentOutOfRangeException"></exception>
    public void SetUpImageVisual(PlayerUIImage imageType, Sprite imageSprite)
    {
        switch (imageType)
        {
            case PlayerUIImage.PlayerCharacter:
                if (playerCharacterImage == null) return;
                playerCharacterImage.sprite = imageSprite;
          
                break;

            case PlayerUIImage.AutoAttack:
                if (autoAttackImage == null) return;
                autoAttackImage.sprite = imageSprite;
                break;

            case PlayerUIImage.Spell01:
                if (spell01Image == null) return;
                spell01Image.sprite = imageSprite;
                spell01CooldownTxt.enabled = false;
                spell01Cooldown.fillAmount = 0;
                break;

            case PlayerUIImage.Spell02:
                if (spell02Image == null) return;
                spell02Image.sprite = imageSprite;
                spell02CooldownTxt.enabled = false;
                spell02Cooldown.fillAmount = 0;
                break;

            case PlayerUIImage.Ward:
                if (wardImage == null) return;
                wardImage.sprite = imageSprite;
                wardCooldownTxt.enabled = false;
                wardCooldown.fillAmount = 0;
                break;

            default: throw new ArgumentOutOfRangeException(nameof(imageType), imageType, null);
        }
    }

    /// <summary>
    /// Update the timer of the spells
    /// </summary>
    /// <param name="spellType"></param>
    /// <param name="cooldownValue"></param>
    /// <param name="maxCooldownValue"></param>
    /// <exception cref="ArgumentOutOfRangeException"></exception>
    public void UpdateSpellTimer(PlayerUIImage spellType, float cooldownValue, float maxCooldownValue)
    {
        switch (spellType)
        {
            case PlayerUIImage.PlayerCharacter: break;

            case PlayerUIImage.AutoAttack: break;
            
            case PlayerUIImage.Spell01:
                spell01CooldownTxt.enabled = true;
                spell01Cooldown.fillAmount = 1-cooldownValue / maxCooldownValue;
                spell01CooldownTxt.text = (Mathf.Round((maxCooldownValue-cooldownValue) * 10f) / 10f).ToString();
                if (cooldownValue == 0)
                {
                    spell01Cooldown.fillAmount = 0;
                    spell01CooldownTxt.enabled = false;
                }
                break;

            case PlayerUIImage.Spell02:
                spell02CooldownTxt.enabled = true;
                spell02Cooldown.fillAmount = 1-cooldownValue / maxCooldownValue;
                spell02CooldownTxt.text = (Mathf.Round((maxCooldownValue-cooldownValue) * 10f) / 10f).ToString();
                if (cooldownValue == 0)
                {
                    spell02Cooldown.fillAmount = 0;
                    spell02CooldownTxt.enabled = false;
                }
                break;

            case PlayerUIImage.Ward:
                wardCooldownTxt.enabled = true;
                wardCooldown.fillAmount = 1-cooldownValue / maxCooldownValue;
                wardCooldownTxt.text = (Mathf.Round((maxCooldownValue-cooldownValue) * 10f) / 10f).ToString();
                if (cooldownValue == 0)
                {
                    wardCooldown.fillAmount = 0;
                    wardCooldownTxt.enabled = false;
                }
                break;

            default: throw new ArgumentOutOfRangeException(nameof(spellType), spellType, null);
        }
    }

    /// <summary>
    /// Change the value of the recast cooldown
    /// </summary>
    /// <param name="cooldownValue"></param>
    /// <param name="maxCooldownValue"></param>
 
   
    public void ChangeRecastCooldown(float cooldownValue, float maxCooldownValue) {
       
        spell01RecastImage.fillAmount = 1-cooldownValue / maxCooldownValue;
        spell01Cooldown.fillAmount = 0;
        if (cooldownValue == 0) {
            spell01RecastImage.fillAmount = 0;
        }
    }
    
   
    
    /// <summary>
    /// Change the value of the recast cooldown
    /// </summary>
    /// <param name="cooldownValue"></param>
    /// <param name="maxCooldownValue"></param>
    public void CancelRecacstCooldown() {
        spell01RecastImage.fillAmount = 0;
        spell01Cooldown.fillAmount = 1;
    }

    /// <summary>
    /// Change the state of the aura (enable, disable)
    /// </summary>
    /// <param name="isActiv"></param>
    public void ChangeAuraState(bool isActiv)
    {
        AADamagebtn.interactable = isActiv;
        COMP01Damagebtn.interactable = isActiv;
        LifePointbtn.interactable = isActiv;
    }

    /// <summary>
    /// Update the gold value of each team
    /// </summary>
    /// <param name="value"></param>
    public void UpdateGoldTeam01(int value, int targetValue) {
        team01GoldImgValue.fillAmount = (float) value / targetValue;
        team01GoldValue.text = value.ToString();
    }

    public void UpdateGoldTeam02(int value, int targetValue) {
        team02GoldImgValue.fillAmount = (float) value / targetValue;
        team02GoldValue.text = value.ToString();
    }

    /// <summary>
    /// Update the Streak of each team
    /// </summary>
    /// <param name="value"></param>
    //public void UpdateStreakTeam01(int value) => team01StreakValue.text = $"Streak : {value}";
    //public void UpdateStreakTeam02(int value) => team02StreakValue.text = $"Streak : {value}";

    /// <summary>
    /// Update the Streak gold value of each team
    /// </summary>
    /// <param name="value"></param>
    public void UpdateGoldStreakTeam01(int value) => team01GoldStreak.text = value.ToString();
    public void Team01Exchange() => team01GoldExchangeAnim.SetTrigger("Exchange");

    public void UpdateGoldStreakTeam02(int value) => team02GoldStreak.text = value.ToString();
    public void Team02Exchange() => team02GoldExchangeAnim.SetTrigger("Exchange");

    /// <summary>
    /// Update the victory point of each team
    /// </summary>
    /// <param name="currentValue"></param>
    /// <param name="maxValue"></param>
    public void UpdateVictoryTeam01(float currentValue,float maxValue) => team01VictoryPoint.fillAmount = currentValue / maxValue;
    public void UpdateVictoryTeam02(float currentValue,float maxValue) => team02VictoryPoint.fillAmount = currentValue / maxValue;

    /// <summary>
    /// Update the number of aura available
    /// </summary>
    /// <param name="auraValue"></param>
    public void UpdateNumberOfAuraAvailable(int auraValue) {
        auraAvailableTxt.text = auraValue.ToString();
        auraAvailableImg.fillAmount = auraValue / 3f;
    }
    
    public void UpdateAuraValue(int auraValue,AuraUIImage auraUIImage) {
        Debug.Log(auraValue + " " + auraUIImage);
        switch (auraUIImage) {
            case AuraUIImage.Comp01Damage : {
                CompAuraImages[auraValue].SetActive(true);
                //COMP01DamageText.text = auraValue.ToString();
                break;
            }
            case AuraUIImage.AADamage : {
                AAAuraImages[auraValue].SetActive(true);
                //AADamageText.text = auraValue.ToString();
                break;
            }
            case AuraUIImage.LifePoint : {
                LifeAuraImages[auraValue].SetActive(true);
                //LifePointText.text = auraValue.ToString();
                break;
            }
        }
    }
    public void SetUpAuraSprite(int auraValue, AuraUIImage auraUIImage,GlobalDelegates.NoParameterDelegate capacity)
    {
       UpdateAuraValue(auraValue, auraUIImage);
       
       switch (auraUIImage)
       {
           case AuraUIImage.Comp01Damage :
           {
               COMP01Damagebtn.onClick.AddListener(new UnityAction(capacity));
               break;
           }
           case AuraUIImage.AADamage :
           {
               AADamagebtn.onClick.AddListener(new UnityAction(capacity));
               break;
           }
           case AuraUIImage.LifePoint :
           {
               LifePointbtn.onClick.AddListener(new UnityAction(capacity));
               break;
           }
       }
    }

    /// <summary>
    /// Update the color of the relai
    /// </summary>
    /// <param name="team"></param>
    /// <exception cref="ArgumentOutOfRangeException"></exception>
    public void UpdateNorthRelaiTeam(Enums.Team team) {
        Debug.Log(team);
        switch (team) {
            case Enums.Team.Neutral:
                northRelaiBlue.SetActive(false);
                northRelaiRed.SetActive(false);
                break;
            case Enums.Team.Team1:
                northRelaiBlue.SetActive(true);
                northRelaiRed.SetActive(false);
                break;
            case Enums.Team.Team2:
                northRelaiBlue.SetActive(false);
                northRelaiRed.SetActive(true);
                break;
            default:
                throw new ArgumentOutOfRangeException(nameof(team), team, null);
        }
    }
    public void UpdateSouthRelaiTeam(Enums.Team team) {
        
        Debug.Log(team);
        switch (team) {
            case Enums.Team.Neutral:
                southRelaiBlue.SetActive(false);
                southRelaiRed.SetActive(false);
                break;
            case Enums.Team.Team1:
                southRelaiBlue.SetActive(true);
                southRelaiRed.SetActive(false);
                break;
            case Enums.Team.Team2:
                southRelaiBlue.SetActive(false);
                southRelaiRed.SetActive(true);
                break;
            default:
                throw new ArgumentOutOfRangeException(nameof(team), team, null);
        }
    }
    
    /// <summary>
    /// Update the generator fill amount value based on each color
    /// </summary>
    /// <param name="value"></param>
    /// <param name="startValue"></param>
    /// <param name="target"></param>
    /// <param name="team"></param>
    /// <exception cref="ArgumentOutOfRangeException"></exception>
    public void UpdateVictoryGenerator(float value, float startValue , float target, Enums.Team team) {
        
        Debug.Log(target);
        Debug.Log(value);
        Debug.Log(startValue);
        float currentResolution = Mathf.Abs(target - value) / Mathf.Abs(target - startValue);
        if (currentResolution < 0.1f)
            currentResolution = 0;
        switch (team) {
            case Enums.Team.Neutral: break;
            
            case Enums.Team.Team1:
                blueGeneratorValue.fillAmount = currentResolution;
                break;
            
            case Enums.Team.Team2:
                redGeneratorValue.fillAmount = currentResolution;
                break;
            
            default: throw new ArgumentOutOfRangeException(nameof(team), team, null);
        }
    }
}

/// <summary>
/// Player Interface Element
/// </summary>
public enum PlayerUIImage
{
    PlayerCharacter,
    AutoAttack,
    Spell01,
    Spell02,
    Ward
}
public enum AuraUIImage {
    Comp01Damage, LifePoint, AADamage
}


