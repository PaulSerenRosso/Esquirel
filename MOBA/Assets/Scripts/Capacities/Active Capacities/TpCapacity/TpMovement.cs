using System;
using System.Collections;
using System.Collections.Generic;
using Entities.FogOfWar;
using GameStates;
using Photon.Pun;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.AI;

namespace Entities.Capacities
{
public class TpMovement : ChampionCapacityCurveMovement
{
    [SerializeField] private TpObject tpObject;

    [SerializeField] private SacDeFarineRotate _sacDeFarineRotate;
    private TpCapacitySO tpCapacitySo;
    private void Start()
    {
        endCurveEvent += tpObject.DeactivateTpObject;
        
        if(PhotonNetwork.IsMasterClient)
        endCurveEvent += CreateSmoke;
    }
    
    void CreateSmoke()
    {
        Smoke smoke = (Smoke) PoolNetworkManager.Instance.PoolInstantiate(tpCapacitySo.smokePrefab, transform.position,
            Quaternion.identity);
       smoke.ChangeTeamRPC((byte)champion.team);
       StartCoroutine(smoke.SetUp(curveMovementCapacity,tpCapacitySo.smokeDuration, tpCapacitySo.smokePrefab, transform.position));
       
    }
    public override void SetUp(byte capacityIndex, int championIndex)
    {
        base.SetUp(capacityIndex, championIndex);
        tpCapacitySo = (TpCapacitySO)curveCapacitySo;
    
    }

    protected override void StartCurveMovementRPC( Vector3 startPos,Vector3 endPos)
    {
        base.StartCurveMovementRPC(startPos, endPos);
        tpObject.ActivateTpObject(transform.position, champion.team);
        
    }

    protected override void OnUpdate()
    {
        if(!tpObject.GetIsActive()) return;
        base.OnUpdate();
        _sacDeFarineRotate.OnUpdate();
    }
    

    
   
    
}
}
