using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

namespace Entities.Capacities
{
public class ActiveAttackCapacityFX : ActiveCapacityFX
{
  public override void InitCapacityFX(ActiveCapacity capacity)
  {
    ActiveAttackCapacity activeAttackCapacity = (ActiveAttackCapacity)capacity;

    transform.position += activeAttackCapacity.champion.rotateParent.forward*activeAttackCapacity.so.offsetAttack;
  }
}
}
