using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

namespace Entities.Capacities
{
    
    public class ActiveAttackWithColliderSlowAreaCapacity: ActiveAttackWithColliderCapacity
    {
        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
            if (base.TryCast(targetsEntityIndexes, targetPositions))
            { 
                return true;
            }
            return false;
        }

        protected override void EndAttackTimer()
        {
            base.EndAttackTimer();
        }

        public override void SyncCapacity(int[] targetsEntityIndexes, Vector3[] targetPositions, params object[] customParameters)
        {
        
            base.SyncCapacity(targetsEntityIndexes, targetPositions, customParameters);
        }
    }
}