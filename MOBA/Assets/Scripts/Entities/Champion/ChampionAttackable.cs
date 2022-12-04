using Entities.Capacities;
using UnityEngine;
using Photon.Pun;

namespace Entities.Champion
{
    public partial class Champion : IAttackable
    {
        public byte attackAbilityIndex;
        public bool canAttack;
        public float attackDamage;
        
        
        
        public bool CanAttack()
        {
            return canAttack;
        }

        public void RequestSetCanAttack(bool value) { }

        [PunRPC]
        public void SyncSetCanAttackRPC(bool value) { }

        [PunRPC]
        public void SetCanAttackRPC(bool value) { }

        public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanAttack;
        public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanAttackFeedback;
        public float GetAttackDamage() => attackDamage;

        public void RequestSetAttackDamage(float value)
        {
            photonView.RPC("SetAttackDamageRPC",RpcTarget.MasterClient,value);
        }

        public void SetAttackDamageRPC(float value)
        {
            attackDamage = value;
            OnSetAttackDamage?.Invoke(value);
            photonView.RPC("SyncSetAttackDamageRPC",RpcTarget.All,attackDamage);
        }
        
        public void SyncSetAttackDamageRPC(float value)
        {
            attackDamage = value;
            OnSetAttackDamageFeedback?.Invoke(value);
        }
        
        public event GlobalDelegates.OneParameterDelegate<float> OnSetAttackDamage;
        public event GlobalDelegates.OneParameterDelegate<float> OnSetAttackDamageFeedback;
        // move 
        // je click si je touche un entity alors je try de lancer le check detection 
        // je click si je touche une position ou autre je move
        // si je suis à portée je je m'arrete et je commence à attaquer 
        // je lance mon attack 
        // si je suis en cooldown 
        

        public void RequestAttack(byte capacityIndex, int[] targetedEntities, Vector3[] targetedPositions)
        {
         
            if (!attackBase.onCooldown)
            {
                photonView.RPC("AttackRPC",RpcTarget.MasterClient,capacityIndex,targetedEntities,targetedPositions);
            }
        }

        [PunRPC]
        public void AttackRPC(byte capacityIndex, int[] targetedEntities, Vector3[] targetedPositions)
        {
            if ( attackBase.TryCast( targetedEntities, targetedPositions))
            {
                CancelCurrentCapacity();
             
               RequestSetCurrentCapacityUsedEqualToAttackBase();
                OnAttack?.Invoke(capacityIndex, targetedEntities, targetedPositions);
      
            }
        }
        
        [PunRPC]
        public void SyncAttackRPC(byte capacityIndex, int[] targetedEntities, Vector3[] targetedPositions)
        {
            
            OnAttackFeedback?.Invoke(capacityIndex,targetedEntities,targetedPositions);
        }

        public event GlobalDelegates.ThirdParameterDelegate<byte , int[] , Vector3[]> OnAttack;
        public event GlobalDelegates.ThirdParameterDelegate<byte , int[] , Vector3[]> OnAttackFeedback;
    }
}