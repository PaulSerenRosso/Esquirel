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
            if (count > so.rankedDamageFactors.Count)
            {
                Debug.LogError("out of range");
                return;
            }

            base.OnAddedEffects(target);
            if (attackCapacityToIncreaseDamage == null)
            {
                so = (PassiveCapacityDamageIncreaserSO)CapacitySOCollectionManager.Instance.GetPassiveCapacitySOByIndex(
                    indexOfSo);

                var capacitiesToIncrease =
                    champion.activeCapacities.Where(capacity =>
                        so.attackCapacitySoToIncreaseDamage.Contains(
                            CapacitySOCollectionManager.GetActiveCapacitySOByIndex(capacity.indexOfSOInCollection)));
                if (!capacitiesToIncrease.Any())
                {
                    return;
                }

                attackCapacityToIncreaseDamage = (ActiveAttackCapacity)capacitiesToIncrease.First();
            }
            attackCapacityToIncreaseDamage.damage =
                attackCapacityToIncreaseDamage.so.damage * so.rankedDamageFactors[count - 1];
        }

        public override void SyncOnAdded(Entity target)
        {
            base.SyncOnAdded(target);
            champion = (Champion.Champion)target;
            champion.auraProduction.UpdateAuraCapacityCounts(so, count);
        }
    }
}