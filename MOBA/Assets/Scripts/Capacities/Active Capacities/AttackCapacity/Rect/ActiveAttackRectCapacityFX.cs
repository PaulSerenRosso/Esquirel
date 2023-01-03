using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;
using UnityEngine.Serialization;

namespace Entities.Capacities
{
 public class ActiveAttackRectCapacityFX : ActiveAttackCapacityFX
 {

  [SerializeField] protected GameObject fxObject;
 [SerializeField] private BoxCollider fogDetection;
  public override void InitCapacityFX(int entityIndex, byte capacityIndex)
  {
   base.InitCapacityFX( entityIndex, capacityIndex);
   ActiveCapacity capacity;
   if (capacityIndex == 255)
    capacity =champion.attackBase;
   else   capacity = champion.activeCapacities[capacityIndex];
   ActiveAttackRectCapacitySO activeAttackRectCapacitySo =(ActiveAttackRectCapacitySO) CapacitySOCollectionManager.GetActiveCapacitySOByIndex(capacity.indexOfSOInCollection);
 
 
   fxObject.transform.SetGlobalScale(new Coordinate[]
   {
    new Coordinate(CoordinateType.X, activeAttackRectCapacitySo.width),
    new Coordinate(CoordinateType.Z, activeAttackRectCapacitySo.height)
   });
   var boxCollider = fogDetection;
   var boxColliderCenter = boxCollider.center;
   var boxColliderSize = boxCollider.size;
   boxColliderSize.z = activeAttackRectCapacitySo.height;
   boxColliderSize.x = activeAttackRectCapacitySo.width;
   boxColliderCenter.z = activeAttackRectCapacitySo.height / 2;
   boxCollider.center = boxColliderCenter;
   boxCollider.size = boxColliderSize;
  }
  


 }
}
 
