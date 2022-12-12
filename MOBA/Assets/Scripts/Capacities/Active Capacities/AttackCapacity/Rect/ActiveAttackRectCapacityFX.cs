using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

namespace Entities.Capacities
{
 public class ActiveAttackRectCapacityFX : ActiveAttackCapacityFX
 {

  [SerializeField] protected GameObject fxObject;
  [SerializeField] private BoxCollider boxCollider;
  public override void InitCapacityFX(ActiveCapacity attackCapacity)
  {
   base.InitCapacityFX(attackCapacity);
   ActiveAttackRectCapacity activeAttackRectCapacity = (ActiveAttackRectCapacity)attackCapacity;
   ActiveAttackRectCapacitySO activeAttackRectCapacitySo = (ActiveAttackRectCapacitySO)activeAttackRectCapacity.so;
   transform.SetGlobalScale(new Coordinate[]
   {
    new Coordinate(CoordinateType.X, activeAttackRectCapacitySo.width),
    new Coordinate(CoordinateType.Z, activeAttackRectCapacitySo.height)
   });
 
   fxObject.transform.SetGlobalScale(new Coordinate[]
   {
    new Coordinate(CoordinateType.X, activeAttackRectCapacitySo.width),
    new Coordinate(CoordinateType.Z, activeAttackRectCapacitySo.height)
   });
   var boxColliderCenter = boxCollider.center;
   boxColliderCenter.z = activeAttackRectCapacitySo.width / 2;
   boxCollider.center = boxColliderCenter;
  }
 }
}
 
