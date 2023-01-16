using System;
using System.Collections;
using System.Collections.Generic;
using GameStates;
using UnityEngine;
using UnityEngine.UI;

public partial class UIManager
{
    
    private void Start()
    {
        playerInterface.SetColorVictoryTeam01();
        playerInterface.SetColorVictoryTeam02();
    }

    public void UpdateSlider(float currentPointVictory, float maxPointVictory, Enums.Team team)
    {
        if (team == Enums.Team.Team1)
        {
            playerInterface.UpdateVictoryTeam01(currentPointVictory, maxPointVictory);
        }
            else
        {
            playerInterface.UpdateVictoryTeam02(currentPointVictory, maxPointVictory);
        }

    }
}