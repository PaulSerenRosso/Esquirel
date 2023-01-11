using System.Collections.Generic;
using UnityEngine;

namespace RessourceProduction
{
[CreateAssetMenu(menuName = "RessourceProduction/GoldProductionSO", fileName = "GoldProductionSO")]
public class GoldProductionSO : CapturePointTickProductionSO<float>
{
   public List<float> streaks;
   public float victoryAmount;
   public float bountyPercentage;

}
}
