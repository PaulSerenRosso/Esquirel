using System;
using System.Collections;
using System.Collections.Generic;
using RessourceProduction;
using UnityEngine;

namespace RessourceProduction
{
[CreateAssetMenu(menuName = "RessourceProduction/VictoryProductionSO", fileName = "VictoryProductionSO")]
public class VictoryProductionSO : CapturePointTickProductionSO<float>
{
  public List<VictoryStep> victorySteps = new List<VictoryStep>();
}

[Serializable]
public class VictoryStep
{
  public float triggerValue;
  public int auraAmount;
}
}
