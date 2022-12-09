using System;
using System.Collections;
using System.Collections.Generic;
using GameStates;
using UnityEngine;
using UnityEngine.UI;

public partial class UIManager
{
   [SerializeField]
   private Image firstTeamVictoryPointSlider;

   [SerializeField] private Image secondTeamVictoryPointSlider;

   private Image currentSlider;

   private void Start()
   {
       firstTeamVictoryPointSlider.color = GameStateMachine.Instance.GetTeamColor(Enums.Team.Team1);
       secondTeamVictoryPointSlider.color = GameStateMachine.Instance.GetTeamColor(Enums.Team.Team2);
   }

   public void UpdateSlider(float currentPointVictory,  float maxPointVictory, Enums.Team team)
   {
       if (team == Enums.Team.Team1)
       {
           currentSlider = firstTeamVictoryPointSlider;
       }
       else
       {
           currentSlider = secondTeamVictoryPointSlider;
       }
       currentSlider.fillAmount = currentPointVictory / maxPointVictory;
   }
}
