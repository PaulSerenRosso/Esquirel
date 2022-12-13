using System.Collections;
using System.Collections.Generic;
using GameStates;
using UnityEngine;
using UnityEngine.AI;

namespace Entities.Capacities
{
    
    public class ActiveTrinketCapacity : ActiveCapacity, IPrevisualisable
    {
        private bool canDraw = true;
        private bool isDrawing = false;
        private ActiveTrinketCapacitySO so;
        private Champion.Champion champion;
        private Trinket currentTrinket;
        private bool canSpawn;
        private NavMeshHit navMeshHit;
        private Vector3 spawnPosition;
        
      public virtual void EnableDrawing()
        {
            isDrawing = true;
            UIManager.Instance.ChangeCursorSpriteToAimSprite();
            GameStateMachine.Instance.OnUpdate += CheckWorldCursorPositionIsInNavmesh;
        }
            
        public virtual void DisableDrawing()
        {
            isDrawing = false;
            canDraw = false;
            UIManager.Instance.ChangeCursorSpriteToBaseSprite();
        }

        public void CheckWorldCursorPositionIsInNavmesh()
        {
            if (NavMesh.SamplePosition(InputManager.inputMouseWorldPosition, out navMeshHit,
                    so.toleranceNavmeshDetection, 1))
            {
                canSpawn =true;
                spawnPosition = navMeshHit.position;
            }
            else
            {
                canSpawn = false;
                
            }
            
        }
    
        public bool GetIsDrawing()
        {
            return isDrawing;
        }
    
        public void SetIsDrawing(bool value)
        {
            isDrawing = value;
        }
    
        public bool GetCanDraw()
        {
            return canDraw;
        }
    
        public void SetCanDraw(bool value)
        {
            canDraw = value;
        }
    
        public virtual bool TryCastWithPrevisualisableData(int[] targetsEntityIndexes, Vector3[] targetPositions,
            params object[] previsualisableParameters)
        {
             
            return TryCast(targetsEntityIndexes, targetPositions);
        }
    
        public virtual object[] GetPrevisualisableData()
        {
            return null;
        }
    
        public override void SetUpActiveCapacity(byte soIndex, Entity caster)
        {
            base.SetUpActiveCapacity(soIndex, caster);
            champion = (Champion.Champion)caster;
            so = (ActiveTrinketCapacitySO)CapacitySOCollectionManager.GetActiveCapacitySOByIndex(indexOfSOInCollection);
            if (champion.photonView.IsMine)
            {
                champion.OnSetCooldownFeedback += DisableCanDraw;
            }
        }

        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
            if (!onCooldown)
            {
                if (canSpawn)
                {
                currentTrinket = (Trinket) PoolNetworkManager.Instance.PoolInstantiate(so.trinketPrefab, spawnPosition,
                    Quaternion.identity);
                return true;
                }
            }

            return false;
        }

        public override void CancelCapacity()
        {
         
        }

        void DisableCanDraw(byte index, bool value)
        {
            if (index == indexOfSOInCollection)
                canDraw = true;
            GameStateMachine.Instance.OnUpdate -= CheckWorldCursorPositionIsInNavmesh;
        }
    }
}