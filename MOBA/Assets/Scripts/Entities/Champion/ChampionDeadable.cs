using Entities.FogOfWar;
using GameStates;
using Photon.Pun;
using UnityEngine;

namespace Entities.Champion
{
    public partial class Champion : IDeadable
    {
        public bool isAlive;
        public bool canDie;

        // TODO: Delete when TickManager is implemented
        public float respawnDuration = 3;
        private double respawnTimer;

        public bool IsAlive()
        {
            return isAlive;
        }

        public bool CanDie()
        {
            return canDie;
        }

        public void RequestSetCanDie(bool value)
        {
            photonView.RPC("SetCanDieRPC", RpcTarget.MasterClient, value);
        }

        [PunRPC]
        public void SyncSetCanDieRPC(bool value)
        {
            canDie = value;
            OnSetCanDieFeedback?.Invoke(value);
        }

        [PunRPC]
        public void SetCanDieRPC(bool value)
        {
            canDie = value;
            OnSetCanDie?.Invoke(value);
            photonView.RPC("SyncSetCanDieRPC", RpcTarget.All, value);
        }

        public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanDie;
        public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanDieFeedback;

        public void RequestDie()
        {
            photonView.RPC("DieRPC", RpcTarget.MasterClient);
        }

        [PunRPC]
        public void SyncDieRPC()
        {
            if (photonView.IsMine)
            {
                InputManager.PlayerMap.Movement.Disable();
                InputManager.PlayerMap.Attack.Disable();
                InputManager.PlayerMap.Capacity.Disable();
                InputManager.PlayerMap.Inventory.Disable();
            }

            transformView.enabled = false;
            SetCanMoveRPC(false);
            moveDestination  = respawnPos;
            isAlive = false;
            canBeTargeted = false;
            blocker.characterCollider.enabled = false;
             SyncSetCanCatapultMovementRPC(false);
            entityClicker.EnableCollider = false;
            rotateParent.gameObject.SetActive(false);
            entityCapacityCollider.enabled = false;
            uiTransform.gameObject.SetActive(false);
            FogOfWarManager.Instance.RemoveFOWViewable(this);

            OnDieFeedback?.Invoke();
        }

        [PunRPC]
        public void DieRPC()
        {
            if (!canDie)
            {
                Debug.LogWarning($"{name} can't die!");
                return;
            }

            CancelCurrentCapacityRPC();
            RequestResetCapacityAimed();
            if (currentPoint != null)
            {
                switch (team)
                {
                    case Enums.Team.Team1:
                    {
                        currentPoint.RemoveFirstTeamChampion(this);
                        break;
                    }
                    case Enums.Team.Team2:
                    {
                        currentPoint.RemoveSecondTeamChampion(this);
                        break;
                    }
                }
            }

            isAlive = false;

            // TODO - Disable collision, etc...

            OnDie?.Invoke();
            GameStateMachine.Instance.OnTick += Revive;
            photonView.RPC("SyncDieRPC", RpcTarget.All);
        }

        public event GlobalDelegates.NoParameterDelegate OnDie;
        public event GlobalDelegates.NoParameterDelegate OnDieFeedback;

        public void RequestRevive()
        {
            photonView.RPC("ReviveRPC", RpcTarget.MasterClient);
        }

        [PunRPC]
        public void SyncReviveRPC()
        {
            transform.position = respawnPos;
            isAlive = true;
            if (photonView.IsMine)
            {
                InputManager.PlayerMap.Movement.Enable();
                InputManager.PlayerMap.Attack.Enable();
                InputManager.PlayerMap.Capacity.Enable();
                InputManager.PlayerMap.Inventory.Enable();
                agent.enabled = true;
                agent.isStopped = false;
                agent.destination = transform.position;
            }

            SetCanMoveRPC(true);
            canBeTargeted = true;
            SyncSetCanCatapultMovementRPC(true);
            ClearBushes();
            blocker.characterCollider.enabled = true;
            entityClicker.EnableCollider = true;
            FogOfWarManager.Instance.AddFOWViewable(this);
            rotateParent.gameObject.SetActive(true);
            uiTransform.gameObject.SetActive(true);
            entityCapacityCollider.enabled = true;
            OnReviveFeedback?.Invoke();
            transformView.enabled = true;
        }

        [PunRPC]
        public void ReviveRPC()
        {
            isAlive = true;
            SetCurrentHpRPC(maxHp);
            SetCurrentResourceRPC(maxResource);
            OnRevive?.Invoke();
            photonView.RPC("SyncReviveRPC", RpcTarget.All);
        }

        private void Revive()
        {
            respawnTimer += 1 / GameStateMachine.Instance.tickRate;

            if (!(respawnTimer >= respawnDuration)) return;
            GameStateMachine.Instance.OnTick -= Revive;
            respawnTimer = 0f;
            isAlive = true;
            RequestRevive();
        }

        public event GlobalDelegates.NoParameterDelegate OnRevive;
        public event GlobalDelegates.NoParameterDelegate OnReviveFeedback;
    }
}