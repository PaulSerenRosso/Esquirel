using System;
using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;

namespace RessourceProduction
{
    public abstract class CapturePointTickProduction<T> : RessourceTickProduction<T>, IPunObservable
    {
        [SerializeField]
        private CapturePoint.CapturePoint[] allCapturesPoint;
        [SerializeField]
        protected Enums.Team team;

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
            for (int i = 0; i < allCapturesPoint.Length; i++)
            {
                switch (team)
                {
                    case Enums.Team.Team1 :
                    {
                        allCapturesPoint[i].firstTeamState.enterStateEvent += InitiateRessourceProductionTimer;
                        allCapturesPoint[i].firstTeamState.exitStateEvent += CancelRessourceProductionTimer;
                        break;
                    }
                    
                    case Enums.Team.Team2 :
                    {
                        allCapturesPoint[i].secondTeamState.enterStateEvent += InitiateRessourceProductionTimer;
                        allCapturesPoint[i].secondTeamState.exitStateEvent += CancelRessourceProductionTimer;
                        break;
                    }
                }
            }
        }

        private void Start()
        {
            OnStart();
        }
        
        public void OnPhotonSerializeView(PhotonStream stream, PhotonMessageInfo info)
        {
            if (stream.IsWriting)
            {
                stream.SendNext(ressource);
            }
            else
            {
                Ressource = (T)stream.ReceiveNext();
            }
        }
    }
}