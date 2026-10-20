//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "MenuScreen.h"
#include "GUIComponentButton.h"
#include "HookTable.h"

namespace SGG {
class MainMenuScreen : public MenuScreen {
  public:
    GUIComponentButton *GetPlayGameButton() const noexcept { return mPlayGameButton; };
    GUIComponentButton *GetExitButton() const noexcept { return mExitButton; };

    void OpenProfiles() { GET_HOOK(MainMenuScreen_OpenProfiles, void(__fastcall *)(void *))(this); }

  private:
    bool mPressStartMode;
    bool mPressStartAwaitingInput;
    bool mNeedsApplyUserSettings;
    GUIComponentAnimation *mLogo;
    GUIComponentAnimation *mCharacter;
    GUIComponentAnimation *mUpdateTitleBacking;
    GUIComponentAnimation *mNewAnnouncementTag;
    GUIComponentButton *mPlayGameButton;
    GUIComponentButton *mCloudSaveButton;
    GUIComponentButton *mSettingsButton;
    GUIComponentButton *mAnnouncementButton;
    GUIComponentButton *mExitButton;
    GUIComponentTextBox *mLastUpdateText;
    GUIComponentTextBox *mUpdateTitleText;
    GUIComponentTextBox *mControllerWarningText;
    GUIComponentTextBox *mGraphicsDriverWarningText;
    GUIComponentTextBox *mNextUpdateBaseFormat;
    GUIComponentTextBox *mNextUpdateCountFormat;
    GUIComponentButton *mFeedbackButton;
    GUIComponentButton *mWebsiteButton;
    GUIComponentButton *mSoundtrackButton;
    GUIComponentButton *mStoreButton;
    GUIComponentButton *mMailingListButton;
    GUIComponentButton *mNextUpdateButton;
    GUIComponentTextBox *mNextUpdateText;
    GUIComponentButton *mXboxChangeProfileButton;
    GUIComponentButton *mXboxPressStartButton;
    GUIComponentTextBox *mXboxGamertagLabel;
    GUIComponentBox *mFront;
};
static_assert(sizeof(MainMenuScreen) == 0x588, "Size of MainMenuScreen is not 0x588");
} // namespace SGG
