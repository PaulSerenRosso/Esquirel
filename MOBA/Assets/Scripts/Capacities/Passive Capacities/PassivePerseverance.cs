using GameStates;
using UnityEngine;

namespace Entities.Capacities
{
    public class PassivePerseverance : PassiveCapacity
    {
        private double timeSinceLastAttack;
        private double timeSinceLastHeal;
        private PassivePerseveranceSO passiveCapacitySo;
        private IActiveLifeable activeLifeable;
        public float healPercentage;
        
        public override PassiveCapacitySO AssociatedPassiveCapacitySO()
        {
            return CapacitySOCollectionManager.Instance.GetPassiveCapacitySOByIndex(indexOfSo);
        }

        protected override void OnAddedEffects(Entity target)
        {
            passiveCapacitySo = (PassivePerseveranceSO)AssociatedPassiveCapacitySO();

            activeLifeable = entity.GetComponent<IActiveLifeable>();
            Debug.Log("addedpassive" + entity.gameObject.name);
            activeLifeable.OnDecreaseCurrentHp += ResetTimeSinceLastAttack;
            GameStateMachine.Instance.OnTick += IncreasePerTick;
            healPercentage = passiveCapacitySo.percentage;
        }

       

        protected override void OnRemovedEffects(Entity target)
        {
            Debug.LogWarning("RemovedEffect");
            activeLifeable.OnDecreaseCurrentHp -= ResetTimeSinceLastAttack;
            GameStateMachine.Instance.OnTick -= IncreasePerTick;
        }

     

        private void ActiveHealEffect()
        {
            float maxHP = activeLifeable.GetMaxHp();
            float modAmount = maxHP * healPercentage;
            activeLifeable.IncreaseCurrentHpRPC(modAmount);
 
          //  PoolLocalManager.Instance.PoolInstantiate(((PassivePerseveranceSO)AssociatedPassiveCapacitySO()).healEffectPrefab, entity.transform.position, Quaternion.identity,
            //    entity.transform);
        }

        private void IncreasePerTick()
        {

            timeSinceLastAttack += GameStateMachine.Instance.tickRate/60;
            timeSinceLastHeal += GameStateMachine.Instance.tickRate/60;

            if (timeSinceLastAttack > passiveCapacitySo.timeBeforeHealAfterDamage)
            {
                if (timeSinceLastHeal >= passiveCapacitySo.timeBetweenHealTick)
                {
                    ActiveHealEffect();
                    timeSinceLastHeal = 0;
                    Debug.Log(passiveCapacitySo.percentage);
                }
            }
        }

        private void ResetTimeSinceLastAttack(float f)
        {
   
            timeSinceLastAttack = 0;
        }
    }

}
