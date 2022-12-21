using System.Collections.Generic;

namespace Entities.FogOfWar
{
    public interface IFOWViewable
    {
        
        /// <returns>If the entity can see</returns>
        public bool CanView();
        /// <returns>The current view range of the entity</returns>
        public float GetFOWViewRange();
        /// <returns>The base view range of the entity</returns>
        public float GetFOWBaseViewRange();

        public List<IFOWShowable> SeenShowables();

        public void RequestSetCanView(bool value);
        public void SyncSetCanViewRPC(bool value);
        public void SetCanViewRPC(bool value);
        public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanView;
        public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanViewFeedback;
        
        /// <summary>
        /// Sends an RPC to the master to set the entity's view range.
        /// </summary>
        /// <param name="value">the value to set it to</param>
        public void RequestSetViewRange(float value);

        /// <summary>
        /// Sends an RPC to all clients to set the entity's view range.
        /// </summary>
        /// <param name="value">the value to set it to</param>
        public void SyncSetViewRangeRPC(float value);

        /// <summary>
        /// Sets the entity's view range.
        /// </summary>
        /// <param name="value">the value to set it to</param>
        public void SetViewRangeRPC(float value);

        public event GlobalDelegates.OneParameterDelegate<float> OnSetViewRange;
        public event GlobalDelegates.OneParameterDelegate<float> OnSetViewRangeFeedback;
        
        /// <summary>
        /// Sends an RPC to the master to set the entity's view range.
        /// </summary>
        /// <param name="value">the value to set it to</param>
        public void RequestSetViewAngle(float value);

        /// <summary>
        /// Sends an RPC to all clients to set the entity's view range.
        /// </summary>
        /// <param name="value">the value to set it to</param>
        public void SyncSetViewAngleRPC(float value);

        /// <summary>
        /// Sets the entity's view range.
        /// </summary>
        /// <param name="value">the value to set it to</param>
        public void SetViewAngleRPC(float value);

        public event GlobalDelegates.OneParameterDelegate<float> OnSetViewAngle;
        public event GlobalDelegates.OneParameterDelegate<float> OnSetViewAngleFeedback;

        
        //Demander à Gauthier et Hubert 
        public void RequestSetBaseViewRange(float value);
        public void SyncSetBaseViewRangeRPC(float value);
        public void SetBaseViewRangeRPC(float value);
        public event GlobalDelegates.OneParameterDelegate<float> OnSetBaseViewRange;
        public event GlobalDelegates.OneParameterDelegate<float> OnSetBaseViewRangeFeedback;

        public void AddShowable(int showableIndex);
        public void AddShowable(Entity showable);
        public void SyncAddShowableRPC(int showableIndex);

        public bool CheckViewEntitySeeShowableEntityInBush(Entity showable);
        public event GlobalDelegates.OneParameterDelegate<int> OnAddShowable;
        public event GlobalDelegates.OneParameterDelegate<int> OnAddShowableFeedback;
        
        public void RemoveShowable(int showableIndex);
        public void RemoveShowable(IFOWShowable showable);
        public void SyncRemoveShowableRPC(int showableIndex);
        public event GlobalDelegates.OneParameterDelegate<int> OnRemoveShowable;
        public event GlobalDelegates.OneParameterDelegate<int> OnRemoveShowableFeedback;
    }
}