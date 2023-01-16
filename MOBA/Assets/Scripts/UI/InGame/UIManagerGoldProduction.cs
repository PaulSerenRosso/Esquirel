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
  
  public void UpdateGoldText(int value, Enums.Team team)
  {
    switch (team)
    {
      case Enums.Team.Team1:
      {
        playerInterface.UpdateGoldTeam01(value);
        break; 
      }
      case Enums.Team.Team2:
      {
        playerInterface.UpdateGoldTeam02(value);
        break; 
      }
    }
  }

  public void UpdateStreak(int value, int nextValue, Enums.Team team) 
  {
    switch (team)
    {
      case Enums.Team.Team1:
      {
       playerInterface.UpdateStreakTeam01(value);
       playerInterface.UpdateGoldStreakTeam01(nextValue);
        break; 
      }
      case Enums.Team.Team2:
      {
        playerInterface.UpdateStreakTeam02(value);
        playerInterface.UpdateGoldStreakTeam02(nextValue);
        break; 
      }
    }
  }
}
