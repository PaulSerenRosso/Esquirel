using System.Collections;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.ProBuilder.MeshOperations;

namespace Entities.Capacities{
public class CatapultThrowingCapacity : CurveMovementCapacity
{
   private Catapult catapult;
   public override 
      bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
   {
      if(base.TryCast(targetsEntityIndexes, targetPositions))
      {
         champion = (Champion.Champion)EntityCollectionManager.GetEntityByIndex(targetsEntityIndexes[0]);
         SearchEndPositionAvailable();
         
         InitiateCooldown();
         
         // champion 
         // set l'anim 
         // mette un timer avant projection
         // passer en cooldown 
         // quand timer
         // ensuite je lance la projection depuis le catapult
         return true; 
      }
      return false; 
   }

   public override void SyncCapacity(int[] targetsEntityIndexes, Vector3[] targetPositions, params object[] customParameters)
   {
      champion = (Champion.Champion)EntityCollectionManager.GetEntityByIndex(targetsEntityIndexes[0]);
      activeCapacityAnimationLauncher = new ActiveCapacityAnimationLauncher();
      activeCapacityAnimationLauncher.Setup(curveMovementCapacitySo.activeCapacityAnimationLauncherInfo, champion);
      curveObject = champion.catapultMovment;
      champion.RotateMeshChampionRPC(((Vector3)customParameters[1]-(Vector3)customParameters[0]).normalized);
      curveObject.LaunchSetUpRPC(0,caster.entityIndex);
      base.SyncCapacity(targetsEntityIndexes, targetPositions, customParameters);
   }

   public override void SetUpActiveCapacity(byte soIndex, Entity caster)
   {
      base.SetUpActiveCapacity(soIndex, caster);
      startPosition = caster.transform.position;
       catapult = (Catapult)this.caster;
      endPosition = catapult.destination;
      
   }

   public override void InitiateCooldown()
   {
      base.InitiateCooldown();
      catapult.RequestToSetOnCooldownCapacity(indexOfSOInCollection, true);
      
   }

   public override void EndCooldown()
   {
      base.EndCooldown();
      catapult.RequestToSetOnCooldownCapacity(indexOfSOInCollection, false);
   }
}

}
