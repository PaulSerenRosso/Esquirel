using System.Collections;
using System.Collections.Generic;
using AlgebraHelpers;
using Entities.Capacities;
using GameStates;
using RessourceProduction;
using TMPro;
using UnityEngine;

public partial class UIManager
{
  [SerializeField]
  private TextMeshProUGUI goldText;

  [SerializeField]
  private int goldAmount;

  [SerializeField]
  private float percentageHealAmount;

  [SerializeField] private GoldProduction firstTeamGoldProduction;
  [SerializeField] private GoldProduction secondTeamGoldProduction;
  

  
  public void IncreaseHealAmountOfPerseverance()
  {
    var champion = GameStateMachine.Instance.GetPlayerChampion();
    champion.RequestIncreaseHealAmountOfPerseverance(percentageHealAmount);
    if(champion.team == Enums.Team.Team1)
        firstTeamGoldProduction.RequestDecreaseRessource(goldAmount);
      else
        secondTeamGoldProduction.RequestDecreaseRessource(goldAmount);
  }
  public void UpdateGoldText(float value)
  {
    goldText.text = value.ToString();
  }
}
