using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Entities.Capacities
{
public class CatapultMovement : JumpMovement
{
    private CatapultThrowingCapacity catapultThrowingCapacity;
    private Catapult catapult;
    private float championViewRange;
    public override void SetUp(byte capacityIndex, int championIndex)
    {
        catapult =(Catapult) EntityCollectionManager.GetEntityByIndex(championIndex);

        catapultThrowingCapacity =(CatapultThrowingCapacity) catapult.activeCapacities[capacityIndex];
        curveCapacitySo = catapultThrowingCapacity.curveMovementCapacitySo;
        curveMovementCapacity = catapultThrowingCapacity;
        UIRoot = catapultThrowingCapacity.champion.uiTransform;
        base.SetUp(capacityIndex, championIndex);
       
    }

    protected override void StartCurveMovementRPC(Vector3 startPos, Vector3 endPos)
    {
        champion = catapultThrowingCapacity.champion;
        base.StartCurveMovementRPC(startPos, endPos);
        championViewRange = champion.viewRange;
        champion.viewRange = 0;
   
    }

    protected override void DeactivateController()
    {
        base.DeactivateController();
        if (champion.photonView.IsMine)
        {
            InputManager.PlayerMap.MoveMouse.Disable();
        }
    
    }



    protected override void ActivateController()
    {
        base.ActivateController();
        champion.viewRange = championViewRange;
        if (champion.photonView.IsMine)
        {
            InputManager.PlayerMap.MoveMouse.Enable();
        }
    }
    
}
}
