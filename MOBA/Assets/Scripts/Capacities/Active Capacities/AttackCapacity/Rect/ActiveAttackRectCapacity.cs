using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Entities.Capacities
{
    public class ActiveAttackRectCapacity : ActiveAttackWithPrevisualisableCapacity
    {
        private Vector3 previsualisableObjectForward;

        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
            if (base.TryCast(targetsEntityIndexes, targetPositions))
            {
                champion.RequestRotateMeshChampion(previsualisableObjectForward);
                return true;
            }
            return false;
        }

        public override void EnableDrawing()
        {
            base.EnableDrawing();
            InputManager.PlayerMap.MoveMouse.MousePos.performed += RotateDraw;
            previsualisableObjectForward = champion.rotateParent.transform.forward;
            previsualisableObject.transform.forward = previsualisableObjectForward;
        }

        void RotateDraw(InputAction.CallbackContext ctx)
        {
            previsualisableObjectForward = InputManager.inputMouseWorldPosition - champion.transform.position;
            previsualisableObjectForward.y = 0;
            previsualisableObjectForward.Normalize();
            previsualisableObject.transform.forward = previsualisableObjectForward;
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