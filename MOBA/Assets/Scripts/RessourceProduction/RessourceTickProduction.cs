using System.Collections;
using System.Collections.Generic;
using GameStates;
using Photon.Pun;
using UnityEngine;

namespace RessourceProduction
{
    public abstract class RessourceTickProduction<T> : RessourceProduction<T>
    {

        public double timeBetweenTick;
        public double timer;
        public T ressourceAmountPerTick;

        public virtual void InitiateRessourceProductionTimer()
        {
            timer = 0;
            GameStateMachine.Instance.OnTick += TickRessourceProductionTimer;
        }

        public virtual void TickRessourceProductionTimer()
        {
            timer += 1.0 / GameStateMachine.Instance.tickRate;
            if (timer >= timeBetweenTick)
            {
                EndTickRessourceProductionTimer();
            }
        }

        public virtual void EndTickRessourceProductionTimer()
        {
            IncreaseRessource(ressourceAmountPerTick);
            timer -= timeBetweenTick;
        }

        public virtual void CancelRessourceProductionTimer()
        {
            GameStateMachine.Instance.OnTick -= TickRessourceProductionTimer;
        }

   
    }
}