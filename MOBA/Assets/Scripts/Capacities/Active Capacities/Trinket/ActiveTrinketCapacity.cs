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
        public ActiveTrinketCapacitySO so;
        private Champion.Champion champion;
        private Trinket currentTrinket;
        private bool canSpawn;
        private Vector3 spawnPosition;
        private RaycastHit hit;
        
      public virtual void EnableDrawing()
        {
            isDrawing = true;
            CursorManager.Instance.ChangeCursorSpriteToAimSprite();
            GameStateMachine.Instance.OnUpdate += CheckWorldCursorPositionIsInNavmesh;
        }
            
        public virtual void DisableDrawing()
        {
            isDrawing = false;
            CursorManager.Instance.ChangeCursorSpriteToBaseSprite();
            CursorManager.Instance.ChangeCursorSpriteColor(Color.white);
            GameStateMachine.Instance.OnUpdate -= CheckWorldCursorPositionIsInNavmesh;
        }

        public void CheckWorldCursorPositionIsInNavmesh()
        {
            var mouseRay = Camera.main.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(mouseRay, out hit, so.trinketDetectionDistance, so.trinketDetectionMask))
            {
                if (hit.collider.gameObject.layer == LayerMask.NameToLayer("Floor"))
                {
                canSpawn =true;
                spawnPosition = hit.point;
                CursorManager.Instance.ChangeCursorSpriteColor(Color.white);
                return;
                }
            }
            canSpawn = false;
            CursorManager.Instance.ChangeCursorSpriteColor(Color.grey);
            
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
            canSpawn = (bool)previsualisableParameters[0];
            if (canSpawn)
            {
                spawnPosition =(Vector3) previsualisableParameters[1];
                return TryCast(targetsEntityIndexes, targetPositions);
            }
            champion.RequestToSetCanDrawCapacity(indexOfSOInCollection, true);
            return false;
        }
    
        public virtual object[] GetPrevisualisableData()
        {
            return new []{(object) canSpawn, spawnPosition};
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
               
                    InitiateCooldown();
                currentTrinket = (Trinket) PoolNetworkManager.Instance.PoolInstantiate(so.trinketPrefab, spawnPosition,
                    Quaternion.identity);
                currentTrinket.InitTrinket(this);
                return true;

            }

            return false;
        }

        public override void InitiateCooldown()
        {
            base.InitiateCooldown();
            champion.RequestToSetOnCooldownCapacity(indexOfSOInCollection, true);
        }

        public override void EndCooldown()
        {
            base.EndCooldown();
            champion.RequestToSetOnCooldownCapacity(indexOfSOInCollection, false);
        }

        public override void CancelCapacity()
        {
         
        }

        void DisableCanDraw(byte index, bool value)
        {
            if (index == indexOfSOInCollection)
                canDraw = true;
   
        }
    }
}