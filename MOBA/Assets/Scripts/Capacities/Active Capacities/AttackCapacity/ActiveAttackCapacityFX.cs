using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using Entities.FogOfWar;
using UnityEngine;

namespace Entities.Capacities
{
    public class ActiveAttackCapacityFX : ActiveCapacityFX
    {
        protected Champion.Champion champion;
        protected ActiveAttackCapacity ActiveAttackCapacity;

        public override void InitCapacityFX(int entityIndex, byte capacityIndex, Vector3 direction)
        {
            champion = (Champion.Champion)EntityCollectionManager.GetEntityByIndex(entityIndex);
            if (capacityIndex == 255)
                ActiveAttackCapacity = (ActiveAttackCapacity)champion.attackBase;
            else
            {
                ActiveAttackCapacity = (ActiveAttackCapacity)champion.activeCapacities[capacityIndex];
            }
            transform.position +=
                direction* ActiveAttackCapacity.so.offsetAttack + Vector3.up*FogOfWarManager.Instance.startYPositionRay;
            for (int i = 0; i < allParticleSystems.Length; i++)
            {
                var mainModule = allParticleSystems[i].main;
                mainModule.simulationSpeed = 1 / ActiveAttackCapacity.so.fxTime;
            }
            base.InitCapacityFX(entityIndex, capacityIndex, direction);
        }
    }
}