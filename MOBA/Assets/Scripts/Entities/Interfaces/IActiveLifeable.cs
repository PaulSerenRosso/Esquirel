﻿namespace Entities
{
    public interface IActiveLifeable
    {
        /// <returns>The maxHp of the entity</returns>
        public float GetMaxHp();
        /// <returns>The currentHp of the entity</returns>
        public float GetCurrentHp();
        /// <returns>The percentage of currentHp on maxHp of the entity</returns>
        public float GetCurrentHpPercent();

        public bool GetCanDecreaseCurrentHp();
        
        public void RequestSetCanDecreaseCurrentHp(bool value);
        
        
        public void SyncSetCanDecreaseCurrentHpRPC(bool value);
        /// /// <summary>
        /// Sends an RPC to the master to set the entity's maxHp.
        /// </summary>
        /// <param name="value">the value to set it to</param>
        public void RequestSetMaxHp(float value);
        /// <summary>
        /// Sends an RPC to all clients to set the entity's maxHp.
        /// </summary>
        /// <param name="value">the value to set it to</param>
        public void SyncSetMaxHpRPC(float value);
        /// <summary>
        /// Sets the entity's maxHp.
        /// </summary>
        /// <param name="value">the value to set it to</param>
        public void SetMaxHpRPC(float value);

        public event GlobalDelegates.OneParameterDelegate<float> OnSetMaxHp;
        public event GlobalDelegates.OneParameterDelegate<float> OnSetMaxHpFeedback;
        
        /// <summary>
        /// Sends an RPC to the master to increase the entity's maxHp.
        /// </summary>
        /// <param name="amount">the increase amount</param>
        public void RequestIncreaseMaxHp(float amount);
        /// <summary>
        /// Sends an RPC to all clients to increase the entity's maxHp.
        /// </summary>
        /// <param name="amount">the increase amount</param>
        public void SyncIncreaseMaxHpRPC(float amount);
        /// <summary>
        /// Increases the entity's maxHp.
        /// </summary>
        /// <param name="amount">the increase amount</param>
        public void IncreaseMaxHpRPC(float amount);

        public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseMaxHp;
        public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseMaxHpFeedback;
        
        /// <summary>
        /// Sends an RPC to the master to decrease the entity's maxHp.
        /// </summary>
        /// <param name="amount">the decrease amount</param>
        public void RequestDecreaseMaxHp(float amount);
        /// <summary>
        /// Sends an RPC to all clients to decrease the entity's maxHp.
        /// </summary>
        /// <param name="amount">the increase amount</param>
        public void SyncDecreaseMaxHpRPC(float amount);
        /// <summary>
        /// Decreases the entity's maxHp.
        /// </summary>
        /// <param name="amount">the increase amount</param>
        public void DecreaseMaxHpRPC(float amount);

        public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseMaxHp;
        public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseMaxHpFeedback;

        /// <summary>
        /// Sends an RPC to the master to set the entity's currentHp.
        /// </summary>
        /// <param name="value">the value to set it to</param>
        public void RequestSetCurrentHp(float value);
        /// <summary>
        /// Sends an RPC to all clients to set the entity's currentHp.
        /// </summary>
        /// <param name="value">the value to set it to</param>
        public void SyncSetCurrentHpRPC(float value);
        /// <summary>
        /// Set the entity's currentHp.
        /// </summary>
        /// <param name="value">the value to set it to</param>
        public void SetCurrentHpRPC(float value);

        public event GlobalDelegates.OneParameterDelegate<float> OnSetCurrentHp;
        public event GlobalDelegates.OneParameterDelegate<float> OnSetCurrentHpFeedback;
        
        /// <summary>
        /// Sends an RPC to the master to set the entity's currentHp to a percentage of  its maxHp.
        /// </summary>
        /// <param name="value">the value to set to</param>
        public void RequestSetCurrentHpPercent(float value);
        /// <summary>
        /// Sends an RPC to all clients to set the entity's currentHp to a percentage of  its maxHp.
        /// </summary>
        /// <param name="value">the value to set it to</param>
        public void SyncSetCurrentHpPercentRPC(float value);
        /// <summary>
        /// Sets the entity's currentHp to a percentage of its maxHp.
        /// </summary>
        /// <param name="value">the value to set it to</param>
        public void SetCurrentHpPercentRPC(float value);

        public event GlobalDelegates.OneParameterDelegate<float> OnSetCurrentHpPercent;
        public event GlobalDelegates.OneParameterDelegate<float> OnSetCurrentHpPercentFeedback;
        
        /// <summary>
        /// Sends an RPC to the master to increase the entity's currentHp.
        /// </summary>
        /// <param name="amount">the increase amount</param>
        public void RequestIncreaseCurrentHp(float amount);
        /// <summary>
        /// Sends an RPC to all clients to increase the entity's currentHp.
        /// </summary>
        /// <param name="amount">the increase amount</param>
        public void SyncIncreaseCurrentHpRPC(float amount);
        /// <summary>
        /// Increases the entity's currentHp.
        /// </summary>
        /// <param name="amount">the decrease amount</param>
        public void IncreaseCurrentHpRPC(float amount);

        public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseCurrentHp;
        public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseCurrentHpFeedback;
        
        /// <summary>
        /// Sends an RPC to the master to decrease the entity's currentHp.
        /// </summary>
        /// <param name="amount">the decrease amount</param>
        public void RequestDecreaseCurrentHp(float amount);
        /// <summary>
        /// Sends an RPC to all clients to decrease the entity's currentHp.
        /// </summary>
        /// <param name="amount">the decrease amount</param>
        public void SyncDecreaseCurrentHpRPC(float amount);
        /// <summary>
        /// Decreases the entity's currentHp.
        /// </summary>
        /// <param name="amount">the decrease amount</param>
        public void DecreaseCurrentHpRPC(float amount);

        public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseCurrentHp;
        public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseCurrentHpFeedback;
    }
}

