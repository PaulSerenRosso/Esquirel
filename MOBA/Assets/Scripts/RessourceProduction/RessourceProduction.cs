using System;
using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;

namespace RessourceProduction
{
public abstract class RessourceProduction<T, SO> : MonoBehaviourPun,IPunObservable  where SO : RessourceProductionSO<T>
{
    public T ressource;
    public SO so;

    private void Start()
    {
        OnStart();
    }
    
    public T Ressource
    {
        get
        {
            return ressource; 
        }
        set
        {
            ressource = value;
            
            UpdateFeedback();
        }
    }

    abstract public void UpdateFeedback();
    
   protected virtual void OnStart()
    {
        Ressource = so.ressourceInitial;
    }

    public abstract void IncreaseRessource(T amount);
    
    public abstract void DecreaseRessource(T amount);
    
    public void OnPhotonSerializeView(PhotonStream stream, PhotonMessageInfo info)
    {
        if (stream.IsWriting)
        {
            stream.SendNext(Ressource);
        }
        else
        {
            Ressource = (T)stream.ReceiveNext();
        }
    }
}
}
