using System;
using System.Collections;
using System.Collections.Generic;
using Entities.FogOfWar;
using Photon.Pun;
using Unity.Mathematics;
using UnityEngine;

namespace Entities.Capacities
{
public class TpMovement : CurveMovement
{
    [SerializeField] private TpObject tpObject;
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
       StartCoroutine(smoke.SetUp(tpCapacitySo.smokeDuration, tpCapacitySo.smokePrefab, transform.position));
       
    }
    protected override void SetUp(byte capacityIndex, int championIndex, Vector3 endPos)
    {
        base.SetUp(capacityIndex, championIndex, endPos);
        transform.position = curveMovementCapacity.startPosition;
        tpObject.ActivateTpObject(transform.position, champion.team);
        tpCapacitySo = (TpCapacitySO)curveCapacitySo;
    }

    protected override void OnUpdate()
    {
        if(!tpObject.GetIsActive()) return;
        base.OnUpdate();
    }
}
}
