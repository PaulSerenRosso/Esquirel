using System.Collections;
using System.Collections.Generic;
using GameStates;
using Photon.Pun;
using UnityEngine;

namespace RessourceProduction
{
    public abstract class RessourceTickProduction<T, SO> : RessourceProduction<T, SO> where SO : RessourceTickProductionSO<T>
    {
        private double timer;
        public virtual void InitiateRessourceProductionTimer()
        {
            timer = 0;
            GameStateMachine.Instance.OnTick += TickRessourceProductionTimer;
        }

        public virtual void TickRessourceProductionTimer()
        {
            timer += 1.0 / GameStateMachine.Instance.tickRate;
            if (timer >= so.timeBetweenTick)
            {
                EndTickRessourceProductionTimer();
            }
        }

        public virtual void EndTickRessourceProductionTimer()
        {
            IncreaseRessource(so.ressourceAmountPerTick);
    
            timer -= so.timeBetweenTick;
        }

        public virtual void CancelRessourceProductionTimer()
        {
            GameStateMachine.Instance.OnTick -= TickRessourceProductionTimer;
        }

   
    }
}