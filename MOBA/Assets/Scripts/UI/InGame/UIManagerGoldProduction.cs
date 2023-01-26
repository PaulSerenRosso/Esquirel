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
  
  public void UpdateGoldText(int value, int goldTarget, Enums.Team team)
  {
    switch (team)
    {
      case Enums.Team.Team1:
      {
        playerInterface.UpdateGoldTeam01(value, goldTarget);
        break; 
      }
      case Enums.Team.Team2:
      {
        playerInterface.UpdateGoldTeam02(value, goldTarget);
        break; 
      }
    }
  }

  public void UpdateNorthRelayCaptureState(Enums.Team team )
  {
    playerInterface.UpdateNorthRelaiTeam(team);
  }

  public void UpdateSouthRelayCaptureState(Enums.Team team )
  {
    playerInterface.UpdateSouthRelaiTeam(team);
  }

  public void UpdateStreak(int value, int nextValue, Enums.Team team) 
  {
    switch (team)
    {
      case Enums.Team.Team1:
      {
       //playerInterface.UpdateStreakTeam01(value);
       playerInterface.UpdateGoldStreakTeam01(nextValue);
        break; 
      }
      case Enums.Team.Team2:
      {
        //playerInterface.UpdateStreakTeam02(value);
        playerInterface.UpdateGoldStreakTeam02(nextValue);
        break; 
      }
    }
  }

  public void Team01Exchange() => playerInterface.Team01Exchange();
  public void Team02Exchange() => playerInterface.Team02Exchange();
}
