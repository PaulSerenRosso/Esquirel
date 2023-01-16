using System.Collections.Generic;
using UnityEngine;

namespace RessourceProduction
{
[CreateAssetMenu(menuName = "RessourceProduction/GoldProductionSO", fileName = "GoldProductionSO")]
public class GoldProductionSO : CapturePointTickProductionSO<int>
{
   public List<int> streaks;
   public float victoryAmount;
   public float bountyPercentage;

}
}
