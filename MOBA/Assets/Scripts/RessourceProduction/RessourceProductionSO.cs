using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;

namespace RessourceProduction
{
public abstract class RessourceProductionSO<T> : ScriptableObject
{
    public T ressourceMax;
    public T ressourceMin;
    public T ressourceInitial;
}
}
