using System;
using System.Collections;
using System.Collections.Generic;
using GameStates;
using Photon.Pun;
using UnityEngine;

namespace Entities.FogOfWar
{
public class Smoke : Entity
{
    
    private TimerOneCount smokeTimer;
    private Entity smokeRef;
    [SerializeField] private ParticleSystem particleSystem;
    protected override void OnStart()
    {
        base.OnStart();
        if (PhotonNetwork.IsMasterClient)
        {
            smokeTimer = new TimerOneCount(0);
            smokeTimer.TickTimerEvent += DeactivateSmoke;  
        }
    }

    public IEnumerator SetUp(float duration, Entity smokeRef, Vector3 pos)
    {
        yield return new WaitForEndOfFrame();
        smokeTimer.time = duration;
        smokeTimer.InitiateTimer();
        this.smokeRef = smokeRef;
        RequestSmoke(pos, duration);
        
    }

    void RequestSmoke(Vector3 pos, float time) => photonView.RPC("PlaceSmokeRPC", RpcTarget.All, pos, time );

    [PunRPC]
     void PlaceSmokeRPC(Vector3 pos, float time)
    {
        var mainModule = particleSystem.main;
        mainModule.simulationSpeed = 1/time;
        if(GameStateMachine.Instance.GetPlayerTeam() == team)
            ShowElements();
        else
        {
            HideElements();
        }
    }

    

     void DeactivateSmoke()
    {
        PoolNetworkManager.Instance.PoolRequeue(smokeRef,this);
    }


}
    
}
