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
    public override void SetUp(byte capacityIndex, int championIndex, int championOfPlayerWhoMakesSecondDetectionIndex)
    {
        base.SetUp(capacityIndex, championIndex, championOfPlayerWhoMakesSecondDetectionIndex);
        tpCapacitySo = (TpCapacitySO)curveCapacitySo;
    
    }

    protected override void StartCurveMovementRPC(Vector3 endPos)
    {
        base.StartCurveMovementRPC(endPos);
        clientCountReadyToTP = 0; 
        tpObject.ActivateTpObject(transform.position, champion.team);
        
    }

    protected override void OnUpdate()
    {
        if(!tpObject.GetIsActive()) return;
        base.OnUpdate();
    }


    private int clientCountReadyToTP;

    
    [PunRPC]
    void UpdateClientReadyForTP()
    {
        clientCountReadyToTP++ ;
        if (clientCountReadyToTP == GameStateMachine.Instance.playersReadyDict.Count)
        {
            if(championOfPlayerWhoMakesSecondDetection != GameStateMachine.Instance.GetPlayerChampion()) return;
            Debug.Log(GameStateMachine.Instance.GetPlayerChampion());
            if (NavMesh.SamplePosition(transform.position, out NavMeshHit hit,
                    tpCapacitySo.toleranceSecondDetection, 1))
            {
                champion.RequestMoveChampion(hit.position);
            }
        }
    }
    
}
}
