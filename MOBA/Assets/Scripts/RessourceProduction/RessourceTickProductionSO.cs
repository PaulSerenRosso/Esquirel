using System.Collections;
using System.Collections.Generic;
using GameStates;
using Photon.Pun;
using UnityEngine;

namespace RessourceProduction
{
    public abstract class RessourceTickProductionSO<T> : RessourceProductionSO<T>
    {
        public double timeBetweenTick;
        public T ressourceAmountPerTick;
    }
}