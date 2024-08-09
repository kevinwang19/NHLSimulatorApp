//
//  PlayerStatsGridView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-07.
//

import SwiftUI

struct PlayerStatsGridView: View {
    @Binding var skaterStats: [SkaterStat]
    @Binding var goalieStats: [GoalieStat]
    var position: String
    private let seasonColumnWidth: CGFloat = 70
    private let statColumnWidth: CGFloat = 50
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                LazyVStack {
                    ScrollView(.horizontal) {
                        VStack {
                            if position != PositionType.goalies.rawValue {
                                // Header titles for skater stats
                                HStack {
                                    HStack {
                                        HStack {
                                            Text(StatColumnHeader.season.localizedString)
                                                .frame(width: seasonColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.gamesPlayed.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.goals.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.assists.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.points.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.plusMinus.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.pim.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                        }
                                        HStack {
                                            Text(StatColumnHeader.powerPlayGoals.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.powerPlayPoints.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.shorthandedGoals.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.shorthandedPoints.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.otGoals.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.gameWinningGoals.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.shots.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.shootingPctg.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.avgToi.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.faceoffWinningPctg.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                        }
                                    }
                                    .appTextStyle()
                                    .font(.footnote)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Rows of skater stats data
                                ForEach(skaterStats, id: \.self) { item in
                                    HStack {
                                        HStack {
                                            let seasonString = String(item.season)
                                            let formattedSeason = "\(seasonString.prefix(4))-\(seasonString.suffix(2))"
                                            Text(formattedSeason)
                                                .frame(width: seasonColumnWidth, alignment: .center)
                                            Text("\(item.gamesPlayed)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text("\(item.goals)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text("\(item.assists)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text("\(item.points)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text("\(item.plusMinus)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text("\(item.pim)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                        }
                                        HStack {
                                            Text("\(item.powerPlayGoals)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text("\(item.powerPlayPoints)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text("\(item.shorthandedGoals)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text("\(item.shorthandedPoints)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text("\(item.otGoals)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text("\(item.gameWinningGoals)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text("\(item.shots)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(String(format: "%.2f", item.shootingPctg * 100))
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(item.avgToi)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(String(format: "%.2f", item.faceoffWinningPctg * 100))
                                                .frame(width: statColumnWidth, alignment: .center)
                                        }
                                    }
                                    .appTextStyle()
                                    .font(.footnote)
                                    .padding(.vertical, 5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .cornerRadius(10)
                                }
                            } else {
                                // Header titles for goalie stats
                                HStack {
                                    HStack {
                                        HStack {
                                            Text(StatColumnHeader.season.localizedString)
                                                .frame(width: seasonColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.gamesPlayed.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.gamesStarted.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.wins.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.losses.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.otLosses.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                        }
                                        HStack {
                                            Text(StatColumnHeader.goalsAgainst.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.goalsAgainstAvg.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.savePctg.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.shotsAgainst.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(StatColumnHeader.shutouts.localizedString)
                                                .frame(width: statColumnWidth, alignment: .center)
                                        }
                                    }
                                    .appTextStyle()
                                    .font(.footnote)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Rows of goalie stats data
                                ForEach(goalieStats, id: \.self) { item in
                                    HStack {
                                        HStack {
                                            let seasonString = String(item.season)
                                            let formattedSeason = "\(seasonString.prefix(4))-\(seasonString.suffix(2))"
                                            Text(formattedSeason)
                                                .frame(width: seasonColumnWidth, alignment: .center)
                                            Text("\(item.gamesPlayed)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text("\(item.gamesStarted)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text("\(item.wins)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text("\(item.losses)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text("\(item.otLosses)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                        }
                                        HStack {
                                            Text("\(item.goalsAgainst)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(String(format: "%.2f", item.goalsAgainstAvg))
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text(String(format: "%.2f", item.savePctg))
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text("\(item.shotsAgainst)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                            Text("\(item.shutouts)")
                                                .frame(width: statColumnWidth, alignment: .center)
                                        }
                                    }
                                    .appTextStyle()
                                    .font(.footnote)
                                    .padding(.vertical, 5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
                .padding(Spacing.spacingExtraSmall)
            }
        }
    }
}
