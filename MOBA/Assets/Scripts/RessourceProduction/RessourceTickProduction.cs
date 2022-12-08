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
            Debug.Log("bonsoir je suis lu à la ressource ");
        }

        public virtual void TickRessourceProductionTimer()
        {
            timer += 1.0 / GameStateMachine.Instance.tickRate;
            Debug.Log("bonsoir je suis lu à la ressdfqfqffdource ");
            if (timer >= so.timeBetweenTick)
            {
                EndTickRessourceProductionTimer();
            }
        }

        public virtual void EndTickRessourceProductionTimer()
        {
            IncreaseRessource(so.ressourceAmountPerTick);
            Debug.Log("IncreaseRessource");
            timer -= so.timeBetweenTick;
        }

        public virtual void CancelRessourceProductionTimer()
        {
            Debug.Log("bonsoir je suis lu à la ressourcefdqsfqdsfqsdfqsdfqdsf ");
            GameStateMachine.Instance.OnTick -= TickRessourceProductionTimer;
        }

   
    }
}