//
//  PlayoffTreeView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-20.
//

import SwiftUI

struct PlayoffTreeView: View {
    @Binding var playoffTreeStats: [SimulationPlayoffTeamStat]
    @Binding var selectedConference: ConferenceType
    private let numRound1Teams: Int = 8
    private let numRound2Teams: Int = 4
    private let numRound3Teams: Int = 2
    private let textWidth: CGFloat = 40
    
    var body: some View {
        HStack {
            if selectedConference == .eastern {
                if playoffTreeStats.count >= numRound1Teams {
                    VStack {
                        ForEach(0..<numRound1Teams, id: \.self) { index in
                            let item = playoffTreeStats[index]
                            HStack {
                                Text(item.fullName)
                                    .frame(width: textWidth, alignment: .leading)
                                
                                Text("\(item.wins > 4 ? 4 : item.wins)")
                                    .frame(alignment: .trailing)
                            }
                            .padding(Spacing.spacingExtraSmall)
                            .appButtonStyle()
                            .padding(.bottom, index % 2 == 1 ? Spacing.spacingSmall : 1)
                        }
                    }
                } else {
                    VStack {
                        ForEach(0..<numRound1Teams, id: \.self) { index in
                            HStack {
                                Text("")
                                    .frame(width: textWidth, alignment: .leading)
                                
                                Text("")
                                    .frame(alignment: .trailing)
                            }
                            .padding(Spacing.spacingExtraSmall)
                            .appButtonStyle()
                            .padding(.bottom, index % 2 == 1 ? Spacing.spacingSmall : 1)
                        }
                    }
                }
                
                Spacer()
                
                if playoffTreeStats.count >= (numRound1Teams + numRound2Teams) {
                    VStack {
                        ForEach(numRound1Teams..<(numRound1Teams + numRound2Teams), id: \.self) { index in
                            let item = playoffTreeStats[index]
                            HStack {
                                Text(item.fullName)
                                    .frame(width: textWidth, alignment: .leading)
                                
                                Text("\(item.wins > 8 ? 4 : item.wins - 4)")
                                    .frame(alignment: .trailing)
                            }
                            .padding(Spacing.spacingExtraSmall)
                            .appButtonStyle()
                            .padding(.bottom, index % 2 == 1 ? Spacing.spacingLarge : 1)
                        }
                    }
                } else {
                    VStack {
                        ForEach(numRound1Teams..<(numRound1Teams + numRound2Teams), id: \.self) { index in
                            HStack {
                                Text("")
                                    .frame(width: textWidth, alignment: .leading)
                                
                                Text("")
                                    .frame(alignment: .trailing)
                            }
                            .padding(Spacing.spacingExtraSmall)
                            .appButtonStyle()
                            .padding(.bottom, index % 2 == 1 ? Spacing.spacingLarge : 1)
                        }
                    }
                }
                
                Spacer()
                
                if playoffTreeStats.count >= (numRound1Teams + numRound2Teams + numRound3Teams) {
                    VStack {
                        ForEach((numRound1Teams + numRound2Teams)..<(numRound1Teams + numRound2Teams +  numRound3Teams), id: \.self) { index in
                            let item = playoffTreeStats[index]
                            HStack {
                                Text(item.fullName)
                                    .frame(width: textWidth, alignment: .leading)
                                
                                Text("\(item.wins > 12 ? 4 : item.wins - 8)")
                                    .frame(alignment: .trailing)
                            }
                            .padding(Spacing.spacingExtraSmall)
                            .appButtonStyle()
                        }
                    }
                } else {
                    VStack {
                        ForEach((numRound1Teams + numRound2Teams)..<(numRound1Teams + numRound2Teams +  numRound3Teams), id: \.self) { index in
                            HStack {
                                Text("")
                                    .frame(width: textWidth, alignment: .leading)
                                
                                Text("")
                                    .frame(alignment: .trailing)
                            }
                            .padding(Spacing.spacingExtraSmall)
                            .appButtonStyle()
                        }
                    }
                }
                
                Spacer()
                
                if playoffTreeStats.count >= (numRound1Teams + numRound2Teams + numRound3Teams) && (playoffTreeStats[playoffTreeStats.count - 2].wins >= 12 || playoffTreeStats[playoffTreeStats.count - 1].wins >= 12) {
                    VStack {
                        if playoffTreeStats[playoffTreeStats.count - 2].wins >= 12 {
                            HStack {
                                Text(playoffTreeStats[playoffTreeStats.count - 2].fullName)
                                    .frame(width: textWidth, alignment: .leading)
                                
                                Text("\(playoffTreeStats[playoffTreeStats.count - 2].wins - 12)")
                                    .frame(alignment: .trailing)
                            }
                            .padding(Spacing.spacingExtraSmall)
                            .appButtonStyle()
                        } else {
                            HStack {
                                Text(playoffTreeStats[playoffTreeStats.count - 1].fullName)
                                    .frame(width: textWidth, alignment: .leading)
                                
                                Text("\(playoffTreeStats[playoffTreeStats.count - 1].wins - 12)")
                                    .frame(alignment: .trailing)
                            }
                            .padding(Spacing.spacingExtraSmall)
                            .appButtonStyle()
                        }
                    }
                } else {
                    VStack {
                        HStack {
                            Text("")
                                .frame(width: textWidth, alignment: .leading)
                                
                            Text("")
                                .frame(alignment: .trailing)
                        }
                        .padding(Spacing.spacingExtraSmall)
                        .appButtonStyle()
                    }
                }
            } else {
                if playoffTreeStats.count >= (numRound1Teams + numRound2Teams + numRound3Teams) && (playoffTreeStats[playoffTreeStats.count - 2].wins >= 12 || playoffTreeStats[playoffTreeStats.count - 1].wins >= 12) {
                    VStack {
                        if playoffTreeStats[playoffTreeStats.count - 2].wins >= 12 {
                            HStack {
                                Text(playoffTreeStats[playoffTreeStats.count - 2].fullName)
                                    .frame(width: textWidth, alignment: .leading)
                                
                                Text("\(playoffTreeStats[playoffTreeStats.count - 2].wins - 12)")
                                    .frame(alignment: .trailing)
                            }
                            .padding(Spacing.spacingExtraSmall)
                            .appButtonStyle()
                        } else {
                            HStack {
                                Text(playoffTreeStats[playoffTreeStats.count - 1].fullName)
                                    .frame(width: textWidth, alignment: .leading)
                                
                                Text("\(playoffTreeStats[playoffTreeStats.count - 1].wins - 12)")
                                    .frame(alignment: .trailing)
                            }
                            .padding(Spacing.spacingExtraSmall)
                            .appButtonStyle()
                        }
                    }
                } else {
                    VStack {
                        HStack {
                            Text("")
                                .frame(width: textWidth, alignment: .leading)
                                
                            Text("")
                                .frame(alignment: .trailing)
                        }
                        .padding(Spacing.spacingExtraSmall)
                        .appButtonStyle()
                    }
                }
                
                Spacer()
                
                if playoffTreeStats.count >= (numRound1Teams + numRound2Teams + numRound3Teams) {
                    VStack {
                        ForEach((numRound1Teams + numRound2Teams)..<(numRound1Teams + numRound2Teams +  numRound3Teams), id: \.self) { index in
                            let item = playoffTreeStats[index]
                            HStack {
                                Text(item.fullName)
                                    .frame(width: textWidth, alignment: .leading)
                                
                                Text("\(item.wins > 12 ? 4 : item.wins - 8)")
                                    .frame(alignment: .trailing)
                            }
                            .padding(Spacing.spacingExtraSmall)
                            .appButtonStyle()
                        }
                    }
                } else {
                    VStack {
                        ForEach((numRound1Teams + numRound2Teams)..<(numRound1Teams + numRound2Teams +  numRound3Teams), id: \.self) { index in
                            HStack {
                                Text("")
                                    .frame(width: textWidth, alignment: .leading)
                                
                                Text("")
                                    .frame(alignment: .trailing)
                            }
                            .padding(Spacing.spacingExtraSmall)
                            .appButtonStyle()
                        }
                    }
                }
                
                Spacer()
                
                if playoffTreeStats.count >= (numRound1Teams + numRound2Teams) {
                    VStack {
                        ForEach(numRound1Teams..<(numRound1Teams + numRound2Teams), id: \.self) { index in
                            let item = playoffTreeStats[index]
                            HStack {
                                Text(item.fullName)
                                    .frame(width: textWidth, alignment: .leading)
                                
                                Text("\(item.wins > 8 ? 4 : item.wins - 4)")
                                    .frame(alignment: .trailing)
                            }
                            .padding(Spacing.spacingExtraSmall)
                            .appButtonStyle()
                            .padding(.bottom, index % 2 == 1 ? Spacing.spacingLarge : 1)
                        }
                    }
                } else {
                    VStack {
                        ForEach(numRound1Teams..<(numRound1Teams + numRound2Teams), id: \.self) { index in
                            HStack {
                                Text("")
                                    .frame(width: textWidth, alignment: .leading)
                                
                                Text("")
                                    .frame(alignment: .trailing)
                            }
                            .padding(Spacing.spacingExtraSmall)
                            .appButtonStyle()
                            .padding(.bottom, index % 2 == 1 ? Spacing.spacingLarge : 1)
                        }
                    }
                }
                
                Spacer()
                
                if playoffTreeStats.count >= numRound1Teams {
                    VStack {
                        ForEach(0..<numRound1Teams, id: \.self) { index in
                            let item = playoffTreeStats[index]
                            HStack {
                                Text(item.fullName)
                                    .frame(width: textWidth, alignment: .leading)
                                
                                Text("\(item.wins > 4 ? 4 : item.wins)")
                                    .frame(alignment: .trailing)
                            }
                            .padding(Spacing.spacingExtraSmall)
                            .appButtonStyle()
                            .padding(.bottom, index % 2 == 1 ? Spacing.spacingSmall : 1)
                        }
                    }
                } else {
                    VStack {
                        ForEach(0..<numRound1Teams, id: \.self) { index in
                            HStack {
                                Text("")
                                    .frame(width: textWidth, alignment: .leading)
                                
                                Text("")
                                    .frame(alignment: .trailing)
                            }
                            .padding(Spacing.spacingExtraSmall)
                            .appButtonStyle()
                            .padding(.bottom, index % 2 == 1 ? Spacing.spacingSmall : 1)
                        }
                    }
                }
            }
        }
        .appTextStyle()
        .font(.footnote)
        .padding(.top, Spacing.spacingSmall)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
