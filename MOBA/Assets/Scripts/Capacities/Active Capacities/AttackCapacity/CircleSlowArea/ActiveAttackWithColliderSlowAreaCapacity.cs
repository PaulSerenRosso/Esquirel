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

        public override void SetUpActiveCapacity(byte soIndex, Entity caster)
        {
            base.SetUpActiveCapacity(soIndex, caster);
        }
    }
}