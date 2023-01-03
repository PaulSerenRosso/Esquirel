using System;
using UnityEngine;
using UnityEngine.InputSystem;
using Entities;
using Entities.Capacities;
using Entities.Champion;
using Entities.FogOfWar;
using UnityEngine.AI;

namespace Controllers.Inputs
{
    public class ChampionInputController : PlayerInputController
    {
        private Champion champion;
        private int[] targetEntity;
        private Vector3[] cursorWorldPos;
        private bool isMoving;

        private bool inputsAreLinked = false;
        private Vector2 moveInput;
        private Vector3 moveVector;
        private Camera cam;
        private bool isActivebuttonPress;
        [SerializeField] private LayerMask layerForDetectMovePosition;

        private Catapult catapultTarget;
        private Catapult catapultDetected;
        [SerializeField] private float movePositionDetectionDistance;

        /// <summary>
        /// Actions Performed on Attack Activation
        /// </summary>
        /// <param name="ctx"></param>
        /// <summary>
        /// Actions Performed on Show or Hide Shop
        /// </summary>
        /// <param name="ctx"></param>
        private void OnShowHideShop(InputAction.CallbackContext ctx)
        {
            UIManager.Instance.ShowHideShop();
        }

        /// <summary>
        /// Actions Performed on Capacity 0 Activation
        /// </summary>
        /// <param name="ctx"></param>
        private void OnActivateCapacity0(InputAction.CallbackContext ctx)
        {
            champion.RequestCast(0, targetEntity, cursorWorldPos);
        }

        /// <summary>
        /// Actions Performed on Capacity 1 Activation
        /// </summary>
        /// <param name="ctx"></param>
        private void OnActivateCapacity1(InputAction.CallbackContext ctx)
        {
            champion.RequestCast(1, targetEntity, cursorWorldPos);
        }

        private void OnActivateCapacity2(InputAction.CallbackContext ctx)
        {
            champion.RequestCast(2, targetEntity, cursorWorldPos);
        }

        /// <summary>
        /// Actions Performed on Capacity 2 Activation
        /// </summary>
        /// <param name="ctx"></param>
        private void OnActivateUltimateAbility(InputAction.CallbackContext ctx)
        {
            champion.RequestCast((byte)(champion.activeCapacities.Count - 1), targetEntity, cursorWorldPos);
        }

        private void OnPrintCapacity0Previsualisable(InputAction.CallbackContext ctx)
        {
            champion.LaunchCapacityWithPrevisualisable(0, targetEntity, cursorWorldPos);
        }

        private void OnPrintCapacity1Previsualisable(InputAction.CallbackContext ctx)
        {
            champion.LaunchCapacityWithPrevisualisable(1, targetEntity, cursorWorldPos);
        }

        private void OnPrintCapacity2Previsualisable(InputAction.CallbackContext ctx)
        {
            champion.LaunchCapacityWithPrevisualisable(2, targetEntity, cursorWorldPos);
        }

        private void OnPrintUltimatePrevisualisable(InputAction.CallbackContext ctx)
        {
            champion.LaunchCapacityWithPrevisualisable(3, targetEntity, cursorWorldPos);
        }

        /// <summary>
        /// Actions Performed on Item 0 Activation
        /// </summary>
        /// <param name="ctx"></param>
        private void OnActivateItem0(InputAction.CallbackContext ctx)
        {
            champion.RequestActivateItem(0, targetEntity, cursorWorldPos);
        }

        /// <summary>
        /// Actions Performed on Item 1 Activation
        /// </summary>
        /// <param name="ctx"></param>
        private void OnActivateItem1(InputAction.CallbackContext ctx)
        {
            champion.RequestActivateItem(1, targetEntity, cursorWorldPos);
        }

        /// <summary>
        /// Actions Performed on Item 2 Activation
        /// </summary>
        /// <param name="ctx"></param>
        private void OnActivateItem2(InputAction.CallbackContext ctx)
        {
            champion.RequestActivateItem(2, targetEntity, cursorWorldPos);
        }

        private void Update()
        {
            if (!inputsAreLinked) return;
            var mouseRay = cam.ScreenPointToRay(Input.mousePosition);
            if (!Physics.Raycast(mouseRay, out var hit, movePositionDetectionDistance,
                    layerForDetectMovePosition)) return;
            cursorWorldPos[0] = hit.point;
            targetEntity[0] = -1;
            InputManager.inputMouseWorldPosition = hit.point;
            InputManager.inputMouseHit = hit;
            //Debug.Log("hit"+hit.collider.gameObject.name);
            var ent = hit.transform.GetComponent<Entity>();
            //    if (ent == null && hit.transform.parent != null) hit.transform.parent.GetComponent<Entity>();
            if (ent != null)
            {
                // Debug.Log("hitentity");
                if (ent is ITargetable)
                {
                    ITargetable entTarget = (ITargetable)ent;
                    if (entTarget.CanBeTargeted())
                    {
                        // Debug.Log("set list input");
                        targetEntity[0] = ent.entityIndex;
                        cursorWorldPos[0] = ent.transform.position;
                    }
                }
                else if (ent is Catapult catapult)
                {
                    catapultDetected = catapult;
                }
            }
            else
            {
                catapultDetected = null;
                targetEntity[0] = -1;
            }

            if (isActivebuttonPress)
            {
                SelectMoveTarget();
            }

            if (catapultTarget != null)
            {

                if (catapultTarget.requestSended)
                {
                    catapultTarget = null;
                    return;
                }
                if (champion.isAlive)
                {
                    catapultTarget.RequestCast(0, new int[] { champion.entityIndex },
                    new Vector3[] { champion.transform.position });
                }
            }
        }

        void OnMouseRightClick(InputAction.CallbackContext ctx)
        {
            SelectMoveTarget();
        }

        void OnMouseLeftClick(InputAction.CallbackContext ctx)
        {
            champion.CancelPrevisualisable();
        }

        public void SelectMoveTarget()
        {
            if (catapultDetected!= null)
            {
                catapultTarget = catapultDetected;
                champion.MoveToPosition(cursorWorldPos[0]);
                return;
            }
            else
            {
                catapultTarget = null;
            }

            if (targetEntity[0] != -1)
            {
                //   Debug.Log(selectedEntity[0] != -1);
                Entity targetEntity = EntityCollectionManager.GetEntityByIndex(this.targetEntity[0]);
                if (FogOfWarManager.Instance.CheckEntityIsVisibleForPlayer(targetEntity))
                {
                    // Debug.Log(FogOfWarManager.Instance.CheckEntityIsVisibleForPlayer(targetEntity));
                    if (champion.autoAttack.TryAim(champion.entityIndex, this.targetEntity[0], cursorWorldPos[0]))
                    {
                        //   Debug.Log(champion.autoAttack.TryAim(champion.entityIndex, selectedEntity[0], cursorWorldPos[0]));
                        champion.StartMoveToTarget(EntityCollectionManager.GetEntityByIndex(this.targetEntity[0]),
                            champion.attackBase, champion.RequestAttack);
                    }
                    else
                    {
                        champion.MoveToPosition(cursorWorldPos[0]);
                    }
                }
                else
                {
                    champion.MoveToPosition(cursorWorldPos[0]);
                }
            }
            else
            {
                champion.MoveToPosition(cursorWorldPos[0]);
            }
        }


        /// <summary>
        /// Get World Position of mouse
        /// </summary>
        /// <param name="mousePos"></param>
        /// <returns></returns>
        public Vector3 GetMouseOverWorldPos()
        {
            Ray mouseRay = cam.ScreenPointToRay(Input.mousePosition);

            if (Physics.Raycast(mouseRay, out RaycastHit hit))
            {
                return hit.point;
            }

            return Vector3.zero;
        }

        /// <summary>
        /// Actions Performed on Move inputs direction Change
        /// </summary>
        /// <param name="ctx"></param>
        void OnMoveChange(InputAction.CallbackContext ctx)
        {
            moveInput = ctx.ReadValue<Vector2>();
            moveVector = new Vector3(moveInput.x, 0, moveInput.y);
            champion.SetMoveDirection(moveVector);
            NavMeshAgent agent;
        }


        public override void Link(Entity entity)
        {
            champion = controlledEntity as Champion;
            base.Link(entity);

            cam = Camera.main;
            targetEntity = new int[1];
            cursorWorldPos = new Vector3[1];


            inputs.Capacity.Capacity0.performed += OnActivateCapacity0;
            inputs.Capacity.Capacity1.performed += OnActivateCapacity1;
            inputs.Capacity.Capacity2.performed += OnActivateCapacity2;
            inputs.Capacity.Capacity3.performed += OnActivateUltimateAbility;
            inputs.Capacity.PrevisualisableCapacity0.performed += OnPrintCapacity0Previsualisable;
            inputs.Capacity.PrevisualisableCapacity1.performed += OnPrintCapacity1Previsualisable;
            inputs.Capacity.PrevisualisableCapacity2.performed += OnPrintCapacity2Previsualisable;
            inputs.Capacity.PrevisualisableCapacity3.performed += OnPrintUltimatePrevisualisable;
            inputs.MoveMouse.CancelButton.performed += OnMouseLeftClick;

            inputs.MoveMouse.ActiveButton.performed += OnMouseRightClick;
            inputs.MoveMouse.ActiveButton.started += context => isActivebuttonPress = true;
            inputs.MoveMouse.ActiveButton.canceled += context => isActivebuttonPress = false;

            inputsAreLinked = true;

            inputs.Inventory.ActivateItem0.performed += OnActivateItem0;
            inputs.Inventory.ActivateItem1.performed += OnActivateItem1;
            inputs.Inventory.ActivateItem2.performed += OnActivateItem2;
            inputs.Inventory.ShowHideInventory.started += context => UIManager.Instance.ShowHideInventory(true);
            inputs.Inventory.ShowHideInventory.canceled += context => UIManager.Instance.ShowHideInventory(false);
            inputs.Inventory.ShowHideShop.performed += OnShowHideShop;
        }

        public override void Unlink()
        {
            inputsAreLinked = false;
            inputs.Capacity.Capacity0.performed -= OnActivateCapacity0;
            inputs.Capacity.Capacity1.performed -= OnActivateCapacity1;
            inputs.Capacity.Capacity2.performed -= OnActivateCapacity2;
            inputs.Capacity.Capacity3.performed -= OnActivateUltimateAbility;
            inputs.Capacity.PrevisualisableCapacity0.performed -= OnPrintCapacity0Previsualisable;
            inputs.Capacity.PrevisualisableCapacity1.performed -= OnPrintCapacity1Previsualisable;
            inputs.Capacity.PrevisualisableCapacity2.performed -= OnPrintCapacity2Previsualisable;
            inputs.Capacity.PrevisualisableCapacity3.performed -= OnPrintUltimatePrevisualisable;
            inputs.Inventory.ShowHideShop.performed -= OnShowHideShop;
            inputs.MoveMouse.ActiveButton.performed -= OnMouseRightClick;
            inputs.MoveMouse.CancelButton.performed -= OnMouseLeftClick;
            CameraController.Instance.UnLinkCamera();
        }
    }
}