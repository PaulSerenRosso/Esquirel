using GameStates;
using UnityEngine;

namespace Entities.Capacities
{
    public abstract class ActiveCapacity
    {
        public byte indexOfSOInCollection;
        public Entity caster;
        public double cooldownTimer;
        public bool onCooldown;
        private double fxTimer;
       public Entity fxObject;
        
        public GameObject instantiateFeedbackObj;

        protected int target;
        
     
       protected virtual void InitiateFXTimer()
        {
            fxTimer = AssociatedActiveCapacitySO().fxTime;
            GameStateMachine.Instance.OnTick += TickFxTimer;
            
        }
       protected void TickFxTimer()
        {
            fxTimer -= 1.0 / GameStateMachine.Instance.tickRate;
            if (fxTimer <= 0)
            {
                CancelFXTimer();
            }
        }

       protected virtual void CancelFXTimer()
       {
           if (fxObject != null)
           {
           PoolNetworkManager.Instance.PoolRequeue(AssociatedActiveCapacitySO().fxPrefab, fxObject);
           fxObject = null;
           }
           GameStateMachine.Instance.OnTick -= TickFxTimer;
       }


       protected ActiveCapacitySO AssociatedActiveCapacitySO()
        {
            return CapacitySOCollectionManager.GetActiveCapacitySOByIndex(indexOfSOInCollection);
        }

        public virtual void SetUpActiveCapacity(byte soIndex, Entity caster)
        {
            indexOfSOInCollection = soIndex;
            this.caster = caster;
        }

        #region Cast

    
        /// <returns></returns>
        /// <summary>
        /// Initialize the cooldown of the capacity when used.
        /// </summary>
        public virtual void InitiateCooldown()
        {
            onCooldown = true;
            cooldownTimer = AssociatedActiveCapacitySO().cooldown;
            GameStateMachine.Instance.OnTick += CooldownTimer;
        }

        /// <summary>
        /// Method which update the timer.
        /// </summary>
        protected virtual void CooldownTimer()
        {
            cooldownTimer -= 1.0 / GameStateMachine.Instance.tickRate;
            
            if (cooldownTimer <= 0)
            {
                onCooldown = false;
                EndCooldown();
                GameStateMachine.Instance.OnTick -= CooldownTimer;
            }
        }

        public virtual void EndCooldown()
        {
            
        }


        /// <summary>
        /// Called when trying cast a capacity.
        /// </summary>
        /// <param name="casterIndex"></param>
        /// <param name="targetsEntityIndexes"></param>
        /// <param name="targetPositions"></param>
        /// <returns></returns>
        public abstract bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions);

        #endregion

        #region Feedback
        



        public abstract void CancelCapacity();
        

    

        #endregion
    }
}