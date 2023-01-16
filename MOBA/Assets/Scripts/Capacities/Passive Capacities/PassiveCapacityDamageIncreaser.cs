using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Entities;
using UnityEngine;

namespace Entities.Capacities
{
    public class PassiveCapacityDamageIncreaser : PassiveCapacityAura
    {
        private PassiveCapacityDamageIncreaserSO so;
        private ActiveAttackCapacity attackCapacityToIncreaseDamage;

        protected override void OnAddedEffects(Entity target)
        {
            so = (PassiveCapacityDamageIncreaserSO)CapacitySOCollectionManager.Instance.GetPassiveCapacitySOByIndex(
                indexOfSo);
            if (count > so.rankedDamageFactors.Count)
            {
                Debug.LogError("out of range");
                return;
            }

            base.OnAddedEffects(target);
            if (attackCapacityToIncreaseDamage == null)
            {
                ActiveCapacity capacityToIncrease;
                if (so.attackCapacitySoToIncreaseDamage.Contains(
                        CapacitySOCollectionManager.GetActiveCapacitySOByIndex(
                            champion.attackBase.indexOfSOInCollection)))
                    capacityToIncrease = champion.attackBase;
                else
                {
                    var capacitiesToIncrease =
                        champion.activeCapacities.Where(capacity =>
                            so.attackCapacitySoToIncreaseDamage.Contains(
                                CapacitySOCollectionManager.GetActiveCapacitySOByIndex(capacity.indexOfSOInCollection)));
                    var activeCapacities = capacitiesToIncrease as ActiveCapacity[] ?? capacitiesToIncrease.ToArray();
                     capacityToIncrease = activeCapacities.First();
                }
                  
                if (capacityToIncrease == null)
                {
                    return;
                }

                attackCapacityToIncreaseDamage = (ActiveAttackCapacity)capacityToIncrease;
            }
            attackCapacityToIncreaseDamage.damage =
                attackCapacityToIncreaseDamage.so.damage * so.rankedDamageFactors[count - 1];
//            Debug.Log(  attackCapacityToIncreaseDamage.damage + "cout" + count);
           
        }

        public override void SyncOnAdded(Entity target)
        {
            base.SyncOnAdded(target);
            champion = (Champion.Champion)target;
        }
    }
}