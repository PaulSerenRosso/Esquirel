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
        RequestSmoke(pos);
        
    }

    void RequestSmoke(Vector3 pos) => photonView.RPC("PlaceSmokeRPC", RpcTarget.All, pos);

    [PunRPC]
     void PlaceSmokeRPC(Vector3 pos)
    {
        
    }

    

     void DeactivateSmoke()
    {
        PoolNetworkManager.Instance.PoolRequeue(smokeRef,this);
    }


}
    
}
