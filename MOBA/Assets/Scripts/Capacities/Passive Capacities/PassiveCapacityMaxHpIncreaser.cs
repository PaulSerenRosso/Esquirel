using System.Collections;
using System.Collections.Generic;

using UnityEngine;

namespace Entities.Capacities
{
public class PassiveCapacityMaxHpIncreaser : PassiveCapacityAura
{
  private PassiveCapacityMaxHpIncreaserSO so;
  protected override void OnAddedEffects(Entity target)
  {
    base.OnAddedEffects(target);
  }

  public override void SyncOnAdded(Entity target)
  {
    base.SyncOnAdded(target);
    so =(PassiveCapacityMaxHpIncreaserSO) CapacitySOCollectionManager.Instance.GetPassiveCapacitySOByIndex(indexOfSo);
    champion.IncreaseMaxHpRPC(so.rankedMaxHpFactors[count-1]);
  }
}
}
