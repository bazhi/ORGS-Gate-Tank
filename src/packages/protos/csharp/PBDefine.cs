using Google.Protobuf;
using System.Collections.Generic;
namespace Pb{
    public enum PBDefine{
		Unknow,
		Pack,
		Error,
		Operation,
		CreateRole,
		UpgradeStar,
		UnlockEquipment,
		UpgradeLevel,
		Decompose,
		EnterChapter,
		EnterSection,
		FinishSection,
		FinishMission,
		OpenBox,
		GainBox,
		Delete,
		Role,
		Prop,
		Props,
		Equipment,
		Equipments,
		Chapter,
		Chapters,
		Section,
		SectionResult,
		Sections,
		Mission,
		Missions,
		Box,
		Boxes,
		Reward,
		Rewards,
		SigninRecord
    }

	public static class PBRegister
	{
		public static void Register(ref Dictionary<PBDefine, MessageParser>dict)
		{
			dict.Add(PBDefine.Pack, Pack.Parser);
			dict.Add(PBDefine.Error, Error.Parser);
			dict.Add(PBDefine.Operation, Operation.Parser);
			dict.Add(PBDefine.CreateRole, CreateRole.Parser);
			dict.Add(PBDefine.UpgradeStar, UpgradeStar.Parser);
			dict.Add(PBDefine.UnlockEquipment, UnlockEquipment.Parser);
			dict.Add(PBDefine.UpgradeLevel, UpgradeLevel.Parser);
			dict.Add(PBDefine.Decompose, Decompose.Parser);
			dict.Add(PBDefine.EnterChapter, EnterChapter.Parser);
			dict.Add(PBDefine.EnterSection, EnterSection.Parser);
			dict.Add(PBDefine.FinishSection, FinishSection.Parser);
			dict.Add(PBDefine.FinishMission, FinishMission.Parser);
			dict.Add(PBDefine.OpenBox, OpenBox.Parser);
			dict.Add(PBDefine.GainBox, GainBox.Parser);
			dict.Add(PBDefine.Delete, Delete.Parser);
			dict.Add(PBDefine.Role, Role.Parser);
			dict.Add(PBDefine.Prop, Prop.Parser);
			dict.Add(PBDefine.Props, Props.Parser);
			dict.Add(PBDefine.Equipment, Equipment.Parser);
			dict.Add(PBDefine.Equipments, Equipments.Parser);
			dict.Add(PBDefine.Chapter, Chapter.Parser);
			dict.Add(PBDefine.Chapters, Chapters.Parser);
			dict.Add(PBDefine.Section, Section.Parser);
			dict.Add(PBDefine.SectionResult, SectionResult.Parser);
			dict.Add(PBDefine.Sections, Sections.Parser);
			dict.Add(PBDefine.Mission, Mission.Parser);
			dict.Add(PBDefine.Missions, Missions.Parser);
			dict.Add(PBDefine.Box, Box.Parser);
			dict.Add(PBDefine.Boxes, Boxes.Parser);
			dict.Add(PBDefine.Reward, Reward.Parser);
			dict.Add(PBDefine.Rewards, Rewards.Parser);
			dict.Add(PBDefine.SigninRecord, SigninRecord.Parser);
		}
	}
}