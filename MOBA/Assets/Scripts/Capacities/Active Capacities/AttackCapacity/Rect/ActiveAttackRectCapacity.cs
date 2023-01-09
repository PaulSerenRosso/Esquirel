using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Entities.Capacities
{
    public class ActiveAttackRectCapacity : ActiveAttackWithColliderWithPrevisualisableCapacity
    {
       public  Vector3 previsualisableObjectForward;

       public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
       {
           if (champion.CheckCurrentCapacityForCastableCapacity())
           {
           if (base.TryCast(targetsEntityIndexes, targetPositions))
           {
               
               return true;
           }
           }

           return false;
       }

       protected override void InitiateDamagePrefab()
       {
           base.InitiateDamagePrefab();
       }

       protected override void EndAttackTimer()
       {
           champion.RequestResetCapacityRPC();
       }

       protected override void InitFX(int[] targetsEntityIndexes, Vector3[] targetPositions)
       {
           directionAttack = previsualisableObjectForward;
           fxInfo.fxRotation = Quaternion.LookRotation(directionAttack, Vector3.up);
          base.InitFX(targetsEntityIndexes, targetPositions);
       }


       public override void EnableDrawing()
        {
            base.EnableDrawing();
            InputManager.PlayerMap.MoveMouse.MousePos.performed += RotateDraw;
            previsualisableObjectForward = InputManager.inputMouseWorldPosition - champion.transform.position;
            previsualisableObjectForward.y = 0;
            previsualisableObjectForward.Normalize();
            previsualisableObject.transform.forward = previsualisableObjectForward;
            previsualisableObject.transform.position =
                champion.transform.position + previsualisableObjectForward * so.offsetAttack;
        }

        void RotateDraw(InputAction.CallbackContext ctx)
        {
            previsualisableObjectForward = InputManager.inputMouseWorldPosition - champion.transform.position;
            previsualisableObjectForward.y = 0;
            previsualisableObjectForward.Normalize();
            previsualisableObject.transform.forward = previsualisableObjectForward;
            previsualisableObject.transform.position =
                champion.transform.position + previsualisableObjectForward * so.offsetAttack;
        }

        public override void SyncCapacity(int[] targetsEntityIndexes, Vector3[] targetPositions, params object[] customParameters)
        {
            champion.RotateMeshChampionRPC(previsualisableObjectForward);
            champion.SetCurrentCapacityUsed((byte)champion.activeCapacities.IndexOf(this));
        }

        public override void DisableDrawing()
        {
            base.DisableDrawing();
            InputManager.PlayerMap.MoveMouse.MousePos.performed -= RotateDraw;
        }

        public override bool TryCastWithPrevisualisableData(int[] targetsEntityIndexes, Vector3[] targetPositions,
            params object[] previsualisableParameters)
        {
            previsualisableObjectForward = (Vector3)previsualisableParameters[0];
            
            return base.TryCastWithPrevisualisableData(targetsEntityIndexes, targetPositions,
                previsualisableParameters);
        }

        public override object[] GetPrevisualisableData()
        {
            return new[] { (object)previsualisableObjectForward };
        }
    }
}