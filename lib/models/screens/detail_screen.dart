import React from "react";
import {
  View,
  Text,
  Image,
  ScrollView,
  StyleSheet,
  Platform,
  TouchableOpacity,
} from "react-native";
import { useRouter, useLocalSearchParams } from "expo-router";
import { Feather } from "@expo/vector-icons";
import { useColors } from "@/hooks/useColors";
import { useCountryDetail } from "@/hooks/useCountries";
import ErrorState from "@/components/ErrorState";
import CachedBadge from "@/components/CachedBadge";
import colors from "@/constants/colors";

function DetailRow({ label, value }: { label: string; value: string }) {
  const c = useColors();
  return (
    <View style={styles.detailRow}>
      <Text style={[styles.detailLabel, { color: c.mutedForeground }]}>{label}</Text>
      <Text style={[styles.detailValue, { color: c.foreground }]}>{value || "—"}</Text>
    </View>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  const c = useColors();
  return (
    <View style={[styles.section, { backgroundColor: c.card, borderColor: c.border }]}>
      <Text style={[styles.sectionTitle, { color: c.primary }]}>{title}</Text>
      {children}
    </View>
  );
}

function SkeletonBlock({ width, height = 14 }: { width: string | number; height?: number }) {
  return (
    <View
      style={{
        width: width as number,
        height,
        borderRadius: 6,
        backgroundColor: colors.light.skeleton,
        marginBottom: 8,
      }}
    />
  );
}

export default function DetailScreen() {
  const c = useColors();
  const router = useRouter();
  const { code } = useLocalSearchParams<{ code: string }>();
  const { data: country, isLoading, error, refetch, isFromCache } = useCountryDetail(code ?? "");

  const topInset = Platform.OS === "web" ? 67 : 0;

  if (error) {
    return <ErrorState error={error} onRetry={refetch} />;
  }

  return (
    <ScrollView
      style={{ flex: 1, backgroundColor: c.background }}
      contentContainerStyle={[
        styles.scroll,
        { paddingBottom: Platform.OS === "web" ? 34 : 32 },
      ]}
    >
      {/* Back button */}
      <View style={[styles.backRow, { paddingTop: topInset + 12 }]}>
        <TouchableOpacity
          testID="button-back"
          onPress={() => router.back()}
          style={[styles.backBtn, { backgroundColor: c.card, borderColor: c.border }]}
          activeOpacity={0.7}
        >
          <Feather name="arrow-left" size={18} color={c.foreground} />
          <Text style={[styles.backText, { color: c.foreground }]}>Back</Text>
        </TouchableOpacity>
        {isFromCache && <CachedBadge />}
      </View>

      {isLoading ? (
        <View style={{ padding: 16 }}>
          <View style={[styles.flagSkeleton, { backgroundColor: colors.light.skeleton }]} />
          <SkeletonBlock width="60%" height={24} />
          <SkeletonBlock width="40%" height={16} />
          <View style={{ height: 16 }} />
          <SkeletonBlock width="100%" height={14} />
          <SkeletonBlock width="80%" height={14} />
          <SkeletonBlock width="90%" height={14} />
          <SkeletonBlock width="70%" height={14} />
        </View>
      ) : country ? (
        <>
          {/* Flag */}
          <Image
            testID="img-flag"
            source={{ uri: country.flagPng }}
            style={styles.flag}
            resizeMode="cover"
            accessibilityLabel={`Flag of ${country.name}`}
          />

          {/* Name */}
          <View style={styles.nameBlock}>
            <Text style={[styles.commonName, { color: c.foreground }]}>
              {country.name}
            </Text>
            <Text style={[styles.officialName, { color: c.mutedForeground }]}>
              {country.officialName}
            </Text>
          </View>

          {/* Core facts */}
          <Section title="Overview">
            <DetailRow label="Capital" value={country.capital.join(", ")} />
            <DetailRow label="Region" value={country.region} />
            <DetailRow label="Subregion" value={country.subregion} />
            <DetailRow label="Population" value={country.population.toLocaleString()} />
            <DetailRow label="Area" value={country.area > 0 ? `${country.area.toLocaleString()} km²` : "—"} />
          </Section>

          {/* Currencies */}
          <Section title="Currencies">
            {country.currencies.length === 0 ? (
              <Text style={[styles.detailValue, { color: c.mutedForeground }]}>—</Text>
            ) : (
              country.currencies.map((cur, i) => (
                <DetailRow
                  key={i}
                  label={cur.symbol || ""}
                  value={cur.name}
                />
              ))
            )}
          </Section>

          {/* Languages */}
          <Section title="Languages">
            <Text style={[styles.detailValue, { color: c.foreground }]}>
              {country.languages.length > 0 ? country.languages.join(", ") : "—"}
            </Text>
          </Section>

          {/* Timezones */}
          <Section title="Timezones">
            {country.timezones.slice(0, 6).map((tz, i) => (
              <Text
                key={i}
                style={[styles.detailValue, { color: c.foreground, marginBottom: 4 }]}
              >
                {tz}
              </Text>
            ))}
            {country.timezones.length > 6 && (
              <Text style={[styles.detailLabel, { color: c.mutedForeground }]}>
                +{country.timezones.length - 6} more
              </Text>
            )}
          </Section>
        </>
      ) : null}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  scroll: {
    flexGrow: 1,
  },
  backRow: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 16,
    paddingBottom: 12,
    gap: 12,
  },
  backBtn: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 20,
    borderWidth: 1,
  },
  backText: {
    fontSize: 14,
    fontFamily: "Inter_500Medium",
  },
  flag: {
    width: "100%",
    height: 200,
    backgroundColor: "#e8edf5",
    marginBottom: 16,
  },
  flagSkeleton: {
    width: "100%",
    height: 200,
    borderRadius: 0,
    marginBottom: 16,
  },
  nameBlock: {
    paddingHorizontal: 16,
    marginBottom: 16,
    gap: 4,
  },
  commonName: {
    fontSize: 26,
    fontFamily: "Inter_700Bold",
    lineHeight: 32,
  },
  officialName: {
    fontSize: 14,
    fontFamily: "Inter_400Regular",
    lineHeight: 20,
  },
  section: {
    marginHorizontal: 16,
    marginBottom: 12,
    borderRadius: 12,
    borderWidth: 1,
    padding: 16,
    gap: 2,
  },
  sectionTitle: {
    fontSize: 12,
    fontFamily: "Inter_700Bold",
    letterSpacing: 0.8,
    textTransform: "uppercase",
    marginBottom: 10,
  },
  detailRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-start",
    paddingVertical: 5,
    gap: 12,
  },
  detailLabel: {
    fontSize: 14,
    fontFamily: "Inter_400Regular",
    flex: 1,
  },
  detailValue: {
    fontSize: 14,
    fontFamily: "Inter_500Medium",
    flex: 1.5,
    textAlign: "right",
  },
});
