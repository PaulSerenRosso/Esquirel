using System.Collections;
using System.Collections.Generic;
using RessourceProduction;
using UnityEngine;

namespace RessourceProduction
{
[CreateAssetMenu(menuName = "RessourceProduction/VictoryProductionSO", fileName = "VictoryProductionSO")]
public class VictoryProductionSO : CapturePointTickProductionSO<float>
{
  public List<float> VictorySteps = new List<float>();
}
}
