using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;

namespace RessourceProduction
{
public abstract class RessourceProduction<T> : MonoBehaviourPun
{
    public T ressource;
    public T ressourceMax;
    public T ressourceMin;

    public abstract void IncreaseRessource(T amount);
    
    public abstract void DecreaseRessource(T amount);
}
}
