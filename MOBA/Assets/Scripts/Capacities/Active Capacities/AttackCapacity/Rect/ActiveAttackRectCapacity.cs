using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Entities.Capacities
{
    public class ActiveAttackRectCapacity : ActiveAttackWithPrevisualisableCapacity
    {
       public  Vector3 previsualisableObjectForward;
       
        public override void EnableDrawing()
        {
            base.EnableDrawing();
            InputManager.PlayerMap.MoveMouse.MousePos.performed += RotateDraw;
            previsualisableObjectForward = champion.rotateParent.transform.forward;
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
            rotationFx = Quaternion.LookRotation(previsualisableObjectForward, Vector3.up);
            return base.TryCastWithPrevisualisableData(targetsEntityIndexes, targetPositions,
                previsualisableParameters);
        }

        public override object[] GetPrevisualisableData()
        {
            return new[] { (object)previsualisableObjectForward };
        }
    }
}