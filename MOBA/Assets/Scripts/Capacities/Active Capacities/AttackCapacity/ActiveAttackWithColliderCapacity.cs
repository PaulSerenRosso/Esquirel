
using Photon.Pun;
using UnityEngine;


namespace Entities.Capacities
{
    public class ActiveAttackWithColliderCapacity : ActiveAttackCapacity
    {
        public ActiveAttackWithColliderCapacitySO attackWithColliderCapacitySo;
        
        private ActiveAttackCapacityCollider _capacityColliderObject;
        private GameObject DamageObject;
        
        void InitiateDamagePrefab()
        {
            DamageObject = PoolLocalManager.Instance.PoolInstantiate(attackWithColliderCapacitySo.damagePrefab.gameObject,
                champion.transform.position, champion.rotateParent.rotation);
            var activeCapacityCollider = DamageObject.transform.GetComponent<ActiveCapacityCollider>();
            activeCapacityCollider.InitCapacityCollider(this);
        }
        
        protected virtual void CancelDamagePrefab()
        {
            if (DamageObject != null)
            {
                PoolLocalManager.Instance.EnqueuePool(attackWithColliderCapacitySo.damagePrefab.gameObject, DamageObject);
                DamageObject = null;
            }
            
        }
        
        public override void SetUpActiveCapacity(byte soIndex, Entity caster)
        {
            base.SetUpActiveCapacity(soIndex, caster);
            attackWithColliderCapacitySo = (ActiveAttackWithColliderCapacitySO)so;
            if (PhotonNetwork.IsMasterClient)
            {
                damageTimer.InitiateTimerEvent += InitiateDamagePrefab;
                damageTimer.CancelTimerEvent += CancelDamagePrefab;
                damageTimer.TickTimerEvent += CancelDamagePrefab;
            }

            

       
        }
        
    }
}

