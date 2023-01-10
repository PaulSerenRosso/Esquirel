using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using Entities.FogOfWar;
using UnityEngine;
using UnityEngine.Serialization;

namespace Entities.Capacities
{
 public class ActiveAttackRectCapacityFX : ActiveAttackCapacityFX
 {

  [SerializeField] protected GameObject fxObject;
 [SerializeField] private EntityFogOfWarColliderLinker fogDetection;
  public override void InitCapacityFX(int entityIndex, byte capacityIndex, Vector3 direction)
  {
   base.InitCapacityFX( entityIndex, capacityIndex, direction);
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
   
   fogDetection.gameObject.transform.SetGlobalScale(new Coordinate[]
   {
    new Coordinate(CoordinateType.X, activeAttackRectCapacitySo.width),
    new Coordinate(CoordinateType.Z, activeAttackRectCapacitySo.height)
   });
   var transformLocalPosition = fogDetection.transform.localPosition;
   transformLocalPosition.z =  activeAttackRectCapacitySo.height / 2;
   fogDetection.transform.localPosition = transformLocalPosition;
  }
 }
}
 
