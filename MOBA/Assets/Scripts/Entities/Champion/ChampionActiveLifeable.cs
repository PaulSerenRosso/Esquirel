using Photon.Pun;
using UnityEngine;

namespace Entities.Champion
{
    public partial class Champion : IActiveLifeable
    {
        public float maxHp;
        public float currentHp;
        private bool canDecreaseCurrentHp = true;

        public float GetMaxHp()
        {
            return maxHp;
        }

        public float GetCurrentHp()
        {
            return currentHp;
        }

        public float GetCurrentHpPercent()
        {
            return currentHp / maxHp * 100f;
        }

        public bool GetCanDecreaseCurrentHp()
        {
            return canDecreaseCurrentHp;
        }

        public void RequestSetCanDecreaseCurrentHp(bool value)
        {
            photonView.RPC("SyncSetCanDecreaseCurrentHpRPC", RpcTarget.MasterClient, value);
        }

        [PunRPC]
        public void SyncSetCanDecreaseCurrentHpRPC(bool value)
        {
            canDecreaseCurrentHp = value;
        }

        public void RequestSetMaxHp(float value)
        {
            photonView.RPC("SetMaxHpRPC", RpcTarget.MasterClient, value);
        }

        [PunRPC]
        public void SyncSetMaxHpRPC(float value)
        {
            maxHp = value;
            currentHp = value;
            OnSetMaxHpFeedback?.Invoke(value);
        }

        [PunRPC]
        public void SetMaxHpRPC(float value)
        {
            maxHp = value;
            currentHp = value;
            OnSetMaxHp?.Invoke(value);
            photonView.RPC("SyncSetMaxHpRPC", RpcTarget.All, maxHp);
        }

        public event GlobalDelegates.OneParameterDelegate<float> OnSetMaxHp;
        public event GlobalDelegates.OneParameterDelegate<float> OnSetMaxHpFeedback;

        public void RequestIncreaseMaxHp(float amount)
        {
            photonView.RPC("IncreaseMaxHpRPC", RpcTarget.MasterClient, amount);
        }

        [PunRPC]
        public void SyncIncreaseMaxHpRPC(float amount)
        {
            maxHp = amount;
            OnIncreaseMaxHpFeedback?.Invoke(amount);
        }

        [PunRPC]
        public void IncreaseMaxHpRPC(float amount)
        {
            maxHp += amount;

            if (maxHp < currentHp)
                currentHp = maxHp;
            OnIncreaseMaxHp?.Invoke(amount);
            photonView.RPC("SyncIncreaseMaxHpRPC", RpcTarget.All, maxHp);
        }

        public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseMaxHp;
        public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseMaxHpFeedback;

        public void RequestDecreaseMaxHp(float amount)
        {
            photonView.RPC("DecreaseMaxHpRPC", RpcTarget.MasterClient, amount);
        }

        [PunRPC]
        public void SyncDecreaseMaxHpRPC(float amount)
        {
            maxHp = amount;
            if (maxHp < currentHp)
                currentHp = maxHp;
            OnDecreaseMaxHpFeedback?.Invoke(amount);
        }

        [PunRPC]
        public void DecreaseMaxHpRPC(float amount)
        {
            maxHp -= amount;
            if (maxHp < currentHp)
                currentHp = maxHp;
            OnDecreaseMaxHp?.Invoke(amount);
            photonView.RPC("SyncDecreaseMaxHpRPC", RpcTarget.All, maxHp);
        }

        public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseMaxHp;
        public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseMaxHpFeedback;

        public void RequestSetCurrentHp(float value)
        {
            photonView.RPC("SetCurrentHpRPC", RpcTarget.MasterClient, value);
        }

        [PunRPC]
        public void SyncSetCurrentHpRPC(float value)
        {
            currentHp = value;
            OnSetCurrentHpFeedback?.Invoke(value);
        }

        [PunRPC]
        public void SetCurrentHpRPC(float value)
        {
            currentHp = value;
            OnSetCurrentHp?.Invoke(value);
            photonView.RPC("SyncSetCurrentHpRPC", RpcTarget.All, value);
        }

        public event GlobalDelegates.OneParameterDelegate<float> OnSetCurrentHp;
        public event GlobalDelegates.OneParameterDelegate<float> OnSetCurrentHpFeedback;

        public void RequestSetCurrentHpPercent(float value)
        {
            photonView.RPC("SetCurrentHpPercentRPC", RpcTarget.MasterClient, value);
        }

        [PunRPC]
        public void SyncSetCurrentHpPercentRPC(float value)
        {
            currentHp = value;
            OnSetCurrentHpPercentFeedback?.Invoke(value);
        }

        [PunRPC]
        public void SetCurrentHpPercentRPC(float value)
        {
            currentHp = (value * 100) / maxHp;
            OnSetCurrentHpPercent?.Invoke(value);
            photonView.RPC("SyncSetCurrentHpPercentRPC", RpcTarget.All, value);
        }

        public event GlobalDelegates.OneParameterDelegate<float> OnSetCurrentHpPercent;
        public event GlobalDelegates.OneParameterDelegate<float> OnSetCurrentHpPercentFeedback;

        public void RequestIncreaseCurrentHp(float amount)
        {
            photonView.RPC("IncreaseCurrentHpRPC", RpcTarget.MasterClient, amount);
        }

        [PunRPC]
        public void SyncIncreaseCurrentHpRPC(float amount)
        {
            currentHp = amount;
            OnIncreaseCurrentHpFeedback?.Invoke(amount);
        }

        [PunRPC]
        public void IncreaseCurrentHpRPC(float amount)
        {
            currentHp += amount;
            if (currentHp > maxHp)
                currentHp = maxHp;
            OnIncreaseCurrentHp?.Invoke(amount);
            photonView.RPC("SyncIncreaseCurrentHpRPC", RpcTarget.All, currentHp);
        }

        public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseCurrentHp;
        public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseCurrentHpFeedback;

        public void RequestDecreaseCurrentHp(float amount)
        {
            photonView.RPC("DecreaseCurrentHpRPC", RpcTarget.MasterClient, amount);
        }

        [PunRPC]
        public void SyncDecreaseCurrentHpRPC(float amount)
        {
            currentHp = amount;
            OnDecreaseCurrentHpFeedback?.Invoke(amount);
        }

        [PunRPC]
        public void DecreaseCurrentHpRPC(float amount)
        {
            if (!canDecreaseCurrentHp) return;
            if (isAlive)
            {
                currentHp -= amount;
                OnDecreaseCurrentHp?.Invoke(amount);
                if (currentHp <= 0)
                {
                    currentHp = 0;
                    DieRPC();
                }

                photonView.RPC("SyncDecreaseCurrentHpRPC", RpcTarget.All, currentHp);
            }
        }

        public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseCurrentHp;
        public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseCurrentHpFeedback;
    }
}